//
//  importImages.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 29/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa
import BLServerManager

extension ImportDatabase {
    class Thumbnail {
        
        
        
        static private func getCustomers() -> [CustomerModel.Customer]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let socios = json["socio"] as? [String : Any] else {
                return nil
            }
            
            var list = [[String : Any]]()
            
            for (_, value) in socios {
                guard let fechas = value as? [String : Any] else {
                    return nil
                }
                for (_, value1) in fechas {
                    guard let socio = value1 as? [String: Any] else {
                        break
                    }
                    list.append(socio)
                }
                
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: list, options: []) else {
                return nil
            }
            guard let oldSocios = try? JSONDecoder().decode([ImportDatabase.Customer.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var customers = [CustomerModel.Customer]()
            for i in oldSocios {
                let date = i.fechaIngreso.toDate(formato: "dd-MM-yyyy HH:mm:ss")
                let dateDouble = date?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let dob = i.fechaNacimiento.toDate(formato: "dd-MM-yyyy")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let firstName = i.nombre.condenseWhitespace().capitalized
                let lastName = i.apellido.condenseWhitespace().capitalized
                let fullname = lastName + " " + firstName
                
                let location = CustomerModel.Location(_id: _id,
                                                      longitude: 0.0,
                                                      latitude: 0.0,
                                                      street: i.direccion.condenseWhitespace().capitalized,
                                                      locality: i.localidad.condenseWhitespace().capitalized,
                                                      state: "Buenos Aires".capitalized,
                                                      country: "Argentina".capitalized)
                
                let newCustomer = CustomerModel.Customer(_id: _id,
                                                         uid: i.childID,
                                                         timestamp: dateDouble,
                                                         dni: i.dni,
                                                         lastName: lastName,
                                                         firstName: firstName,
                                                         fullname: fullname,
                                                         thumbnailImage: i.childID,
                                                         email: i.correo,
                                                         phoneNumber: i.telefono,
                                                         user: "SUPER_ROLE",
                                                         location: location,
                                                         dob: dob,
                                                         genero: i.genero,
                                                         obraSocial: i.obraSocial ?? "",
                                                         isEnabled: true)
   
                customers.append(newCustomer)
            }
            
            return customers
            
        }
        
        static private func encodeRegister(_ customer: CustomerModel.Customer) -> [String : Any] {
            let data = try? JSONEncoder().encode(customer)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let customers = ImportDatabase.Thumbnail.getCustomers() else {
                return
            }
            var counter = 0
            var notLoaded = 0
            for customer in customers {
                let imageSemasphore = DispatchSemaphore(value: 0
                )
                ImportDatabase.Thumbnail.downloadImage(childID: customer.uid) { (thumb, image, err) in
                    if err != nil {
                        imageSemasphore.signal()
                    } else {
                        
                        CommonWorker.Image.uploadThumbnail(_id: customer._id!, image: image!) { (success) in
                            if success {
                                counter += 1
                                print("thumbnail uploaded \(counter)/\(customers.count)")
                            } else {
                                notLoaded += 1
                                print("not updated \(notLoaded)")
                            }
                            imageSemasphore.signal()
                        }
                        
                        //move image to different firebase backet and different account
                        if image != nil {
                            ImportDatabase.Storage.uploadPhoto(image: image!, filename: customer._id!) { (uploaded) in
                                if uploaded {
                                    counter += 1
                                    print("\(counter)/\(customers.count)")
                                } else {
                                    notLoaded += 1
                                    print("not uploaded \(notLoaded)")
                                }
                                
                            }
                        }
                        
                    }
                }
                _ = imageSemasphore.wait(timeout: .distantFuture)
                
            }
        }
        
        static func updateCustomer(uid: String, thumbnail: String, completion: @escaping (Bool) -> ()) {
            if thumbnail.isEmpty {
                completion(false)
                return
            }
       
            let body = ["thumbnailImage": thumbnail]
            let endpoint = Endpoint.Create(to: .Customer(.Update(uid: uid, body: body)))
            BLServerManager.ApiCall(endpoint: endpoint) { (response : ResponseModel<CustomerModel.Customer>) in
                completion(true)
            } fail: { (error) in
                completion(false)
            }
        }
        
        static func downloadImage(childID: String, completion: @escaping (String?, NSImage?, Error?) -> ()) {
            
            let endpoint = Endpoint.Create(to: .Image(.LoadBigSizeFromOldBucket(customerUID: childID)))
            
            BLServerManager.ApiCall(endpoint: endpoint) { (imageData) in
                guard let data = imageData, let image = NSImage(data: data) else {
                    completion(nil, nil, nil)
                    return
                }
                
                let thumb = image.crop(size: NSSize(width: ImageSize.thumbnail, height: ImageSize.thumbnail))
                let thumbBase64 = thumb?.convertToBase64
                
                let medium = image.crop(size: NSSize(width: ImageSize.storageSize, height: ImageSize.storageSize))
                
                completion(thumbBase64, medium, nil)
                
            } fail: { (error) in
                completion(nil, nil, error)
            }
        }

    }
    
    
}

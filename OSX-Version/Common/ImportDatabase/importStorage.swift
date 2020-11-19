//
//  importStorage.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 31/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa
import BLServerManager

extension ImportDatabase {
    class Storage {
        
        
        
        static private func getCustomers() -> [CustomerModel.Full]? {
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
            guard let oldSocios = try? JSONDecoder().decode([CustomerModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var customers = [CustomerModel.Full]()
            for i in oldSocios {
                let date = i.fechaIngreso.toDate(formato: "dd-MM-yyyy HH:mm:ss")
                let dateDouble = date?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let dob = i.fechaNacimiento.toDate(formato: "dd-MM-yyyy")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let firstName = i.nombre.condenseWhitespace().capitalized
                let lastName = i.apellido.condenseWhitespace().capitalized
                let fullname = lastName + " " + firstName
                
                
                let newCustomer = CustomerModel.Full(_id: _id,
                                                     uid: i.childID,
                                                     timestamp: dateDouble,
                                                     dni: i.dni,
                                                     lastName: lastName,
                                                     firstName: firstName,
                                                     fullname: fullname,
                                                     thumbnailImage: i.childID,
                                                     street: i.direccion.condenseWhitespace().capitalized,
                                                     locality: i.localidad.condenseWhitespace().capitalized,
                                                     state: "Buenos Aires".capitalized,
                                                     country: "Argentina".capitalized,
                                                     email: i.correo,
                                                     phoneNumber: i.telefono,
                                                     user: "SUPER_ROLE",
                                                     longitude: 0.0,
                                                     latitude: 0.0,
                                                     dob: dob,
                                                     genero: i.genero,
                                                     obraSocial: i.obraSocial ?? "")
                customers.append(newCustomer)
            }
            
            return customers
            
        }
        
        static private func encodeRegister(_ customer: CustomerModel.Full) -> [String : Any] {
            let data = try? JSONEncoder().encode(customer)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        
        static private func getFinalAddress(customer: CustomerModel.Full) -> String {
            let street = customer.street
            let locality = customer.locality
            let state = customer.state
            let country = customer.country
            
            let address = street + " " + locality + " " + state + " " + country
            return address
        }
        
        static func MovePhotosToAnotherFolder() {
            guard let customers = ImportDatabase.Storage.getCustomers() else {
                return
            }
            var counter = 0
            var notLoaded = 0
            for customer in customers {
                let imageSemasphore = DispatchSemaphore(value: 0)
                ImportDatabase.Storage.downloadImage(childID: customer.uid) { (image, err) in
    
                    if err != nil || image == nil {
                        imageSemasphore.signal()
                    } else {
            
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
                    imageSemasphore.signal()
                }
                _ = imageSemasphore.wait(timeout: .distantFuture)
                
            }
        }
        
        static func uploadPhoto(image: NSImage, filename: String, success: @escaping (Bool) -> ()) {
            let userId = UserSession?.uid ?? ""
            let pathImage = "\(userId):customer"
            let net = StorageManager()
            if let imageData = image.tiffRepresentation {
                net.uploadPhoto(path: pathImage, imageData: imageData, nombre: filename, tipo: "jpeg") { (jsonResponse, error) in
                    if jsonResponse != nil {
                        success(true)
                    } else {
                        success(false)
                    }
                }
            }
        }
        
        static func downloadImage(childID: String, completion: @escaping (NSImage?, Error?) -> ()) {
            let endpoint = Endpoint.Create(to: .Image(.LoadBigSizeFromOldBucket(customerUID: childID)))
            
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                guard let data = data, let image = NSImage(data: data) else {
                    completion(nil, nil)
                    return
                }
                let medium = image.crop(size: NSSize(width: ImageSize.storageSize, height: ImageSize.storageSize))
                
                completion(medium, nil)
            } fail: { (error) in
                completion(nil, error)
            }

          

//            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImageFromOldBucket?filename=socios/\(childID).jpeg"
//            let _services = NetwordManager()
//
//            _services.downloadImageFromUrl(url: url) { (image) in
//                guard let image = image else {
//                    completion(nil, nil)
//                    return
//                }
//
//                let medium = image.crop(size: NSSize(width: 150, height: 150))
//
//                completion(medium, nil)
//            } fail: { (err) in
//                completion(nil, err)
//            }
//
        }
        
    }
    
    
}

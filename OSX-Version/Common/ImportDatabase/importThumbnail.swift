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

                        ImportDatabase.Thumbnail.saveNewThumbnail(uid: customer.uid, thumbnail: thumb ?? "") { (success) in
                            if success {
                                counter += 1
                                print("\(counter)/\(customers.count)")
                            } else {
                                notLoaded += 1
                                print("not updated \(notLoaded)")
                            }
                            imageSemasphore.signal()
                        }
                        
                        //move image from different firebase accounts
                        if image != nil {
                            ImportDatabase.Storage.uploadPhoto(image: image!, filename: customer.uid) { (uploaded) in
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
        
        static func saveNewThumbnail(uid: String, thumbnail: String, completion: @escaping (Bool) -> ()) {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            let _services = NetwordManager()
            
            if thumbnail.isEmpty {
                completion(false)
                return
            }
       
            let body = ["uid": uid,
                        "thumbnailImage": thumbnail,
                        "isEnabled" : true] as [String : Any]
            
            _services.post(url: url, body: body) { (data, error) in
                if error != nil {
                    completion(false)
                    return
                }
                guard data != nil else {
                    completion(false)
                    return
                }
                
                completion(true)
                
            }
        }
        
        static func updateCustomer(uid: String, thumbnail: String, completion: @escaping (Bool) -> ()) {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let _services = NetwordManager()
            
            if thumbnail.isEmpty {
                completion(false)
                return
            }
       
            let body = ["uid": uid,
                        "thumbnailImage": thumbnail]
            
            _services.update(url: url, body: body) { (data, error) in
                if error != nil {
                    completion(false)
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
                if let c = json?["customer"] as? [String: Any] {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        static func downloadImage(childID: String, completion: @escaping (String?, NSImage?, Error?) -> ()) {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImageFromOldBucket?filename=socios/\(childID).jpeg"
            let _services = NetwordManager()

            _services.downloadImageFromUrl(url: url) { (image) in
                guard let image = image else {
                    completion(nil, nil, nil)
                    return
                }
                
                let thumb = image.crop(size: NSSize(width: 50, height: 50))
                let thumbBase64 = thumb?.convertToBase64
                
                let medium = image.crop(size: NSSize(width: 150, height: 150))
                
                completion(thumbBase64, medium, nil)
            } fail: { (err) in
                completion(nil, nil, err)
            }

        }

    }
    
    
}

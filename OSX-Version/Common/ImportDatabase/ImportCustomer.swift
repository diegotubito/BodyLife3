//
//  ImportCustomer.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class Customer {
        
        
        
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
                let dob = i.fechaNacimiento.toDate(formato: "dd-MM-yyyy")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
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
            guard let customers = ImportDatabase.Customer.getCustomers() else {
                return
            }
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,customer) in customers.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = encodeRegister(customer)
                _services.post(url: url, body: body) { (data, error) in
                    guard data != nil else {
                        print("no se guardo \(customer.dni) error")
                        print(body)
                        notAdded += 1
                        print("not added \(notAdded)")
                        semasphore.signal()
                        return
                    }
                    semasphore.signal()
                }
                
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(customers.count)")
            }
            print("not added \(notAdded)")
        }
        
        
        static func downloadImage() {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImage?filename=socios/-0JEaB5GvklUIoBcxhGo.jpeg"
            let _services = NetwordManager()
            
            _services.downloadImageFromUrl(url: url) { (image) in
                print("success")
            } fail: { (err) in
                print("error")
            }

        }
    }
    
    
  
    
}

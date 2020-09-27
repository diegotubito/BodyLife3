//
//  ImportCustomer.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

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
                
                let newCustomer = CustomerModel.Full(uid: i.childID,
                                                     timestamp: dateDouble,
                                                     dni: i.dni,
                                                     lastName: i.apellido.condenseWhitespace(),
                                                     firstName: i.nombre.condenseWhitespace(),
                                                     thumbnailImage: i.childID,
                                                     street: i.direccion.condenseWhitespace(),
                                                     locality: i.localidad.condenseWhitespace(),
                                                     state: "Buenos Aires",
                                                     country: "Argentina",
                                                     email: i.correo,
                                                     phoneNumber: i.telefono,
                                                     user: "SUPER_ROLE",
                                                     longitude: 0.0,
                                                     latitude: 0.0)
                customers.append(newCustomer)
            }
            
            return customers
            
        }
        
        static private func getParameters(_ customer: CustomerModel.Full) -> [String : Any] {
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
        
        static func SaveFirebaseCustomersToMongoDB() {
            guard let customers = ImportDatabase.Customer.getCustomers() else {
                return
            }
            let url = "http://127.0.0.1:2999/v1/customer"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,customer) in customers.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = getParameters(customer)
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
    }
}

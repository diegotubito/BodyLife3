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
        
        struct Old: Decodable {
            var apellido : String
            var nombre: String
            var localidad: String
            var telefono: String
            var obraSocial:String?
            var fechaRuta:String
            var genero:String
            var fechaNacimiento: String
            var fechaIngreso:String
            var dni:String
            var direccion:String
            var correo:String
            var childIDUsuario: String?
            var childID: String
        }
        
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
                let dob = i.fechaNacimiento.toDate(formato: "dd-MM-yyyy")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
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
            guard let customers = ImportDatabase.Customer.getCustomers() else {
                return
            }
            var notAdded = 0
            for (x,customer) in customers.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = encodeRegister(customer)
                let endpoint = Endpoint.Create(to: .Customer(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(customer.dni) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(customers.count)")
            }
            print("not added \(notAdded)")
        }
        
     
    }
    
    
  
    
}

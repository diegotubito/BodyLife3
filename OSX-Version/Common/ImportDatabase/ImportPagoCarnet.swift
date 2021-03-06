//
//  ImportPagos.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 30/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class PagoCarnet {
        
        struct OldCarnet : Decodable {
            var childID : String
            var childIDSocio : String
            var childIDVentaCarnet : String
            var esAnulado : Bool
            var fechaCreacion : String
            var importeCobrado : Double
        }
        
        static private func getPagosCarnets() -> [PaymentModel.Register]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let cobro = json["cobro"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = cobro["carnet"] as? [String : Any] else {
                return nil
            }
            
            var list = [[String : Any]]()
            
            for (_, value) in registers {
                guard let fechas = value as? [String : Any] else {
                    return nil
                }
                for (_, value1) in fechas {
                    guard let register = value1 as? [String: Any] else {
                        break
                    }
                    list.append(register)
                }
                
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: list, options: []) else {
                return nil
            }
            guard let oldRegisters = try? JSONDecoder().decode([ImportDatabase.PagoCarnet.OldCarnet].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [PaymentModel.Register]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                   
                let _id = ImportDatabase.codeUID(i.childID)
                let customer = ImportDatabase.codeUID(i.childIDSocio)
                let sell = ImportDatabase.codeUID(i.childIDVentaCarnet)
                
                let newRegister = PaymentModel.Register(_id: _id,
                                                        customer: customer,
                                                        sell: sell,
                                                        isEnabled: !i.esAnulado,
                                                        timestamp: createdAt,
                                                        paidAmount: i.importeCobrado,
                                                        productCategory: ProductCategory.activity.rawValue)
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: PaymentModel.Register) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let cobros = ImportDatabase.PagoCarnet.getPagosCarnets() else {
                return
            }
            var notAdded = 0
            for (x,cobro) in cobros.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.PagoCarnet.encodeRegister(cobro)
                
                let endpoint = Endpoint.Create(to: .Payment(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(cobro.customer) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(cobros.count)")
            }
            print("not added \(notAdded)")
        }
    }
}



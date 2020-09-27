//
//  ImportSells.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

extension ImportDatabase {
    class Carnet {
        static private func getCarnets() -> [SellModel.Register]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let venta = json["venta"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = venta["carnet"] as? [String : Any] else {
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
            guard let oldRegisters = try? JSONDecoder().decode([SellModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [SellModel.Register]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let fromDate = i.fechaInicial.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let toDate = i.fechaVencimiento.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                
                let activity = ImportDatabase.Carnet.decodeCategoria()
                let period = ImportDatabase.Carnet.decodePeriodo()
                
                let newRegister = SellModel.Register(childID: i.childID,
                                                              childIDCustomer: i.childIDSocio,
                                                              childIDDiscount: nil,
                                                              childIDActivity: activity,
                                                              childIDArticle: nil,
                                                              childIDPeriod: period,
                                                              createdAt: createdAt,
                                                              amountDiscounted: 0,
                                                              fromDate: fromDate,
                                                              toDate: toDate,
                                                              amount: 0,
                                                              price: i.precio,
                                                              displayName: "",
                                                              isEnabled: !i.esAnulado,
                                                              payments: nil,
                                                              operationCategory: "",
                                                              queryByDMY: "",
                                                              queryByMY: "",
                                                              queryByY: "",
                                                              balance: i.precio,
                                                              totalPayment: i.precio)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func decodeCategoria() -> String {
            return "definir categorias"
        }
        
        static private func decodePeriodo() -> String {
            return "definir periodo"
        }
        
        static private func encodeSellRegister(_ register: SellModel.Register) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func SaveFirebaseCarnetToMongoDB() {
            guard let carnets = ImportDatabase.Carnet.getCarnets() else {
                return
            }
            let url = "http://127.0.0.1:2999/v1/sell"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,carnet) in carnets.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Carnet.encodeSellRegister(carnet)
                _services.post(url: url, body: body) { (data, error) in
                    guard data != nil else {
                        print("no se guardo \(carnet.displayName) error")
                        print(body)
                        notAdded += 1
                        print("not added \(notAdded)")
                        semasphore.signal()
                        return
                    }
                    semasphore.signal()
                }
                
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(carnets.count)")
            }
            print("not added \(notAdded)")
        }
    }
}

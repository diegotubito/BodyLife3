//
//  ImportSells.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class Carnet {
        static private func getCarnets() -> [SellModel.NewRegister]? {
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
            
            var result = [SellModel.NewRegister]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let fromDate = i.fechaInicial.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let toDate = i.fechaVencimiento.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                
                let _id = ImportDatabase.codeUID(i.childID)
                let customerId = ImportDatabase.codeUID(i.childIDSocio)
                let dicountID = ImportDatabase.codeUID(i.childIDDescuento ?? "")
                let activityID = ImportDatabase.codeUID(i.childIDActividad)
                let periodID = ImportDatabase.codeUID(i.childIDPeriodo)
                
                
                let newRegister = SellModel.NewRegister(_id: _id,
                                                        customer: customerId,
                                                        discount: dicountID == "000000000000000000000000" ? nil : dicountID,
                                                        activity: activityID,
                                                        article: nil,
                                                        period: periodID,
                                                        timestamp: createdAt,
                                                        fromDate: fromDate,
                                                        toDate: toDate,
                                                        quantity: nil,
                                                        isEnabled: !i.esAnulado,
                                                        productCategory: ProductCategory.activity.rawValue,
                                                        price: i.precio,
                                                        priceList: nil,
                                                        priceCost: nil,
                                                        description: i.descripcionActividad + " - " + i.descripcionPeriodo)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: SellModel.NewRegister) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let carnets = ImportDatabase.Carnet.getCarnets() else {
                return
            }
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,carnet) in carnets.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Carnet.encodeRegister(carnet)
                _services.post(url: url, body: body) { (data, error) in
                    guard data != nil else {
                        print("no se guardo \(carnet.customer) error")
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

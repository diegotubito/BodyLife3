//
//  importDiscount.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Foundation
import BLServerManager

extension ImportDatabase {
    class Discount {
        struct Old : Decodable {
            var childID : String
            var descripcion : String
            var esOculto : Bool
            var fechaCreacion : String
            var fechaVencimiento : String
            var multiplicador : Double
        }
        
        
        static private func getDiscounts() -> [DiscountModel.Register]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let conf = json["conf"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = conf["descuento"] as? [String : Any] else {
                return nil
            }
            
            var list = [[String : Any]]()
            
            for (_, value) in registers {
                guard let regs = value as? [String : Any] else {
                    return nil
                }
                list.append(regs)
               
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: list, options: []) else {
                return nil
            }
            guard let oldRegisters = try? JSONDecoder().decode([ImportDatabase.Discount.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [DiscountModel.Register]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let expiration = i.fechaVencimiento.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let newRegister = DiscountModel.Register(_id: _id,
                                                            description: i.descripcion.condenseWhitespace(),
                                                            isEnabled: !i.esOculto,
                                                            expiration: expiration,
                                                            factor: i.multiplicador,
                                                            timestamp: createdAt)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: DiscountModel.Register) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let discounts = ImportDatabase.Discount.getDiscounts() else {
                return
            }
            var notAdded = 0
            for (x,discount) in discounts.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Discount.encodeRegister(discount)
                let endpoint = Endpoint.Create(to: .Discount(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(discount.description) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(discounts.count)")
            }
            print("not added \(notAdded)")
        }
    }
}

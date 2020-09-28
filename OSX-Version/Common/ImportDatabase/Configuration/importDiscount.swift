//
//  importDiscount.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Foundation

extension ImportDatabase {
    class Discount {
        static private func getDiscounts() -> [DiscountModel.NewRegister]? {
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
            guard let oldRegisters = try? JSONDecoder().decode([DiscountModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [DiscountModel.NewRegister]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let expiration = i.fechaVencimiento.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let newRegister = DiscountModel.NewRegister(_id: _id,
                                                            description: i.descripcion.condenseWhitespace(),
                                                            isEnabled: !i.esOculto,
                                                            expiration: expiration,
                                                            factor: i.multiplicador,
                                                            timestamp: createdAt)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: DiscountModel.NewRegister) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let discounts = ImportDatabase.Discount.getDiscounts() else {
                return
            }
            let url = "http://127.0.0.1:2999/v1/discount"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,discount) in discounts.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Discount.encodeRegister(discount)
                _services.post(url: url, body: body) { (data, error) in
                    guard data != nil else {
                        print("no se guardo \(discount.description) error")
                        print(body)
                        notAdded += 1
                        print("not added \(notAdded)")
                        semasphore.signal()
                        return
                    }
                    semasphore.signal()
                }
                
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(discounts.count)")
            }
            print("not added \(notAdded)")
        }
    }
}

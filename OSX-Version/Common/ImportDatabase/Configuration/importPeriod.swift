//
//  importPeriod.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class Period {
        static private func getPeriods() -> [PeriodModel.NewRegister]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let conf = json["conf"] as? [String : Any] else {
                return nil
            }
            
            guard let carnet = conf["carnet"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = carnet["periodo"] as? [String : Any] else {
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
            guard let oldRegisters = try? JSONDecoder().decode([PeriodModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [PeriodModel.NewRegister]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let activity = ImportDatabase.codeUID(i.childIDActividad)
                let newRegister = PeriodModel.NewRegister(_id: _id,
                                                          description: i.descripcion,
                                                          isEnabled: !i.oculto,
                                                          timestamp: createdAt,
                                                          activity: activity,
                                                          price: i.precio,
                                                          days: i.dias)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: PeriodModel.NewRegister) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let periods = ImportDatabase.Period.getPeriods() else {
                return
            }
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/period"
            let _services = NetwordManager()
            var notAdded = 0
            for (x,period) in periods.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Period.encodeRegister(period)
                _services.post(url: url, body: body) { (data, error) in
                    guard data != nil else {
                        print("no se guardo \(period.description) error")
                        print(body)
                        notAdded += 1
                        print("not added \(notAdded)")
                        semasphore.signal()
                        return
                    }
                    semasphore.signal()
                }
                
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(periods.count)")
            }
            print("not added \(notAdded)")
        }
    }
 
}



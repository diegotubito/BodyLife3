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
        
        struct Old: Decodable {
            var childID : String
            var cantidadDeClases : Int
            var fechaCreacion : String
            var oculto : Bool
            var childIDActividad : String
            var descripcion : String
            var dias : Int
            var esPorClase : Bool
            var esPorVencimiento : Bool
            var precio : Double
        }
        
        static private func getPeriods() -> [PeriodModel.Register]? {
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
            guard let oldRegisters = try? JSONDecoder().decode([ImportDatabase.Period.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [PeriodModel.Register]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let activity = ImportDatabase.codeUID(i.childIDActividad)
                let newRegister = PeriodModel.Register(_id: _id,
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
        
        static private func encodeRegister(_ register: PeriodModel.Register) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let periods = ImportDatabase.Period.getPeriods() else {
                return
            }
            var notAdded = 0
            for (x,period) in periods.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Period.encodeRegister(period)
                
                let endpoint = Endpoint.Create(to: .Period(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(period.description) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(periods.count)")
            }
            print("not added \(notAdded)")
        }
    }
 
}



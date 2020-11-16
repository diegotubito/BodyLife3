//
//  importActivity.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class Activity {
        static private func getActivities() -> [ActivityModel.NewRegister]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let conf = json["conf"] as? [String : Any] else {
                return nil
            }
            
            guard let carnet = conf["carnet"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = carnet["actividad"] as? [String : Any] else {
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
            guard let oldRegisters = try? JSONDecoder().decode([ActivityModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [ActivityModel.NewRegister]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
                let newRegister = ActivityModel.NewRegister(_id: _id,
                                                            description: i.descripcion.condenseWhitespace(),
                                                            isEnabled: !i.oculto,
                                                            timestamp: createdAt)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: ActivityModel.NewRegister) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let activities = ImportDatabase.Activity.getActivities() else {
                return
            }
            var notAdded = 0
            for (x,activity) in activities.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Activity.encodeRegister(activity)
                let endpoint = Endpoint.Create(to: .Activity(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(activity.description) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }

                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(activities.count)")
            }
            print("not added \(notAdded)")
        }
    }
 
}


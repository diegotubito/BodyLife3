//
//  AccountWorker.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 09/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

extension CommonWorker {
    public struct CashAccount {
        static func transaction(accountId: String, amount: Double) {
            let path = "/users:\(MainUserSession.GetUID()):cashAccount:\(accountId)"
            let endpoint = Endpoint.Create(to: .Firebase(.Transaction(path: path, key: "amount", amount: amount)))
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                
            } fail: { (error) in
                print("error cash account transaction, this might cause a difference in cash balance", error.rawValue)
            }

        }
        
        static func createCashAccount(account: CashAccountModel) {
            guard let data = try? JSONEncoder().encode(account),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                return
            }
            let path = "/users:\(MainUserSession.GetUID()):cashAccount:\(account.id)"
            let endpoint = Endpoint.Create(to: .Firebase(.Save(path: path, body: json)))
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                
            } fail: { (error) in
                print("could not save cash account", error.rawValue)
            }

        }
    }
}

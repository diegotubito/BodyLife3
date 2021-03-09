//
//  PipMessage.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 09/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

// MARK: This is just for heroku server not to sleep

class WakeMessageToServer {
    static var timer : Timer!
    static var sharedInstance = WakeMessageToServer()
    
    static func sendWakeupPip() {
        timer = Timer.scheduledTimer(withTimeInterval: 60 * 20, repeats: true, block: { (time) in
            let endpoint = Endpoint.Create(to: .CheckServerConnection)
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
               // print("data received from server")
            } fail: { (value) in
               // print("something went wrong with the server")
            }
           
        })
    }
}

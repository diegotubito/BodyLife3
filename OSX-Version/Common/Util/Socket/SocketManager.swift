//
//  SocketManager.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 08/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import SocketIO
import Cocoa
import BLServerManager

class SocketHelper: NSObject {

    static let shared = SocketHelper()

    private let manager = SocketManager(
        socketURL: URL(string: BLServerManager.baseUrl.rawValue)!,
        config: [.forceNew(true)]
    )

    private var socket: SocketIOClient!

    var isConnected: Bool = false

    private override init() {
        super.init()

        socket = manager.defaultSocket

        socket.on(clientEvent: .connect, callback: { data, ack in
            if self.isConnected {return}
            self.isConnected = true
            self.sendNotification(name: .ServerConnected)
        })

        //not working if server is killed
        socket.on(clientEvent: .disconnect, callback: { data, ack in
            if !self.isConnected {return}
            self.isConnected = false
            self.sendNotification(name: .ServerDisconnected)
        })
        
        //added to detect disconnection by server killed
        socket?.onAny({ (event) in
            if let string = event.items?.first as? String {
                print("socket: received - \(string)")
                if string == "Could not connect to the server." {
                    if !self.isConnected {return}
                    self.isConnected = false
                    self.sendNotification(name: .ServerDisconnected)
                }
            }
        })
        
        // Get emit Call via On method ( emit will fire from Node )
        socket.on("messages") { [weak self](data, ack) in
            print("socket: received - \(data)")
            if data.count > 0 {
            }
        }
    }

    private func sendNotification(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: "Servidor Desconectado")
    }

    func connect() {
        if !isConnected {
            socket.connect()
        }
    }

    func disconnect() {
        if isConnected {
            socket.disconnect()
        }
    }
}

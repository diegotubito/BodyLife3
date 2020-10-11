//
//  SocketManager.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 08/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import SocketIO
import Cocoa

class SocketHelper: NSObject {

    static let shared = SocketHelper()

    private let manager = SocketManager(
        socketURL: URL(string: Config.baseUrl.rawValue)!,
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
                if string == "Could not connect to the server." {
                    if !self.isConnected {return}
                    self.isConnected = false
                    self.sendNotification(name: .ServerDisconnected)
                }
            }
        })
    }

    private func sendNotification(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
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

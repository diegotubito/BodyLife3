//
//  Connect.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let ServerDisconnected = Notification.Name("ServerDisconnected")
    static let ServerConnected = Notification.Name("ServerConnected")
    static let CommunicationStablished = Notification.Name("CommunicationStablished")
    static let NeedLogin = Notification.Name("NeedLogin")
    static let TokenExpired = Notification.Name("TokenExpired")
    static let DidLogin = Notification.Name("DidLogin")
}

class Connect {
    static let Shared = Connect()
    
    static func StartListening() {
        self.AddObservers()
        SocketHelper.shared.connect()
    }
    
    static private func AddObservers() {
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(checkUserSession), name: .DidLogin, object: nil)

        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(checkUserSession), name: .TokenExpired, object: nil)
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(socketConnected), name: .ServerConnected, object: nil)
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(socketDisconnected), name: .ServerDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.reachable), name: Notification.Name.Reachability.reachable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.nonReachable), name: Notification.Name.Reachability.notReachable, object: nil)
    }
    
    @objc func socketConnected() {
        //connected
        print("socket noti: connected")
        checkUserSession()
    }

    @objc func socketDisconnected() {
        print("socket noti: disconnected")
    }
    
    @objc func checkUserSession() {
        doCheck()
    }
    
    func doCheck() {
        if let user = UserSaved.GetUser() {
            ServerManager.RefreshToken { (data, error) in
                guard let data = data else {
                    NotificationCenter.default.post(name: .NeedLogin, object: nil, userInfo: nil)
                    return
                }
                
                var userSession = user
                userSession.token = data.token
                UserSaved.Update(userSession)
                UserSession = userSession
                
                
                ServerManager.ConntectMongoDB(uid: userSession.uid) { (connectedToDatabase) in
     
                    if connectedToDatabase {
                        NotificationCenter.default.post(name: .CommunicationStablished, object: nil, userInfo: nil)
                    } else {
                        print("Error grave: No se pudo conectar a la base de datos")
                    }
                }
            }
        } else {
            NotificationCenter.default.post(name: .NeedLogin, object: nil, userInfo: nil)
        }
    }
    
    
    
    private static func checkInternet(result: (Bool) -> ()) {
        if Reachability.sharedInstance.isConnectedToNetwork() {
            result(true)
            
        } else {
            result(false)
        }
    }
    
    @objc static func reachable() {
        print("reachable")
    }
    
    @objc static func nonReachable() {
        print("not reachable")
    }
    
}

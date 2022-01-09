//
//  Connect.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

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
        let endpoint = Endpoint.Create(to: .CheckServerConnection)
        BLServerManager.ApiCall(endpoint: endpoint) { (isConnected: Bool) in
            if isConnected {
                SocketHelper.shared.connect()
            } else {
                NotificationCenter.default.post(name: .ServerDisconnected, object: "Check Server Connection fail", userInfo: nil)
            }
        } fail: { (error) in
            NotificationCenter.default.post(name: .ServerDisconnected, object: "Check Server Connection fail", userInfo: nil)
        }
        
    }
    
    static private func AddObservers() {
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(checkUserSession), name: .DidLogin, object: nil)

        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(refreshToken), name: .TokenExpired, object: nil)
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(socketConnected), name: .ServerConnected, object: nil)
        NotificationCenter.default.addObserver(Connect.Shared, selector: #selector(socketDisconnected), name: .ServerDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.reachable), name: Notification.Name.Reachability.reachable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.nonReachable), name: Notification.Name.Reachability.notReachable, object: nil)
    }
    
    @objc func socketConnected() {
        //connected
        print("Socket notification: Connected.")
        checkUserSession()
    }

    @objc func socketDisconnected() {
        print("Socket notification: Disconnected.")
    }
    
    @objc func checkUserSession() {
        doCheck()
    }
    
    @objc func refreshToken() {
        let endpoint = Endpoint.Create(to: .RefreshToken(body: ["_id" : MainUserSession.GetUID()]))
        BLServerManager.ApiCall(endpoint: endpoint) { (token: ModelRefreshToken) in
            guard let user = MainUserSession.GetUser() else {
                NotificationCenter.default.post(name: .NeedLogin, object: nil, userInfo: nil)
                return
            }
            let tokenData = token
            var userSession = user
            userSession.token = tokenData.token
            MainUserSession.Update(userSession)
            UserSession = userSession
        } fail: { (error) in
           
        }
    }
    
    func doCheck() {
        if let user = MainUserSession.GetUser() {
            print("Connect: User \(String(describing: user.displayName))")
            let endpoint = Endpoint.Create(to: .RefreshToken(body: ["_id" : MainUserSession.GetUID()]))
            BLServerManager.ApiCall(endpoint: endpoint) { (token:ModelRefreshToken) in
                var userSession = user
                userSession.token = token.token
                MainUserSession.Update(userSession)
                UserSession = userSession
                print("Connect: Refresh token SUCCESS")
                //Select database name
                if let uid = userSession.uid {
                    if !self.isAccountEnabled(uid: uid) {
                        return
                    }
                    let endpoint = Endpoint.Create(to: .ConnectToMongoDB(query: "?database=\(uid)"))
                    BLServerManager.ApiCall(endpoint: endpoint) { (success: Bool) in
                        print("Connect: database connection SUCCESS name = \(uid)")
                        NotificationCenter.default.post(name: .CommunicationStablished, object: nil, userInfo: nil)
                    } fail: { (error) in
                        print("Connect: database connection FAIL name = \(uid) - will excecute again do check...")
                        self.doCheck()
                    }
                } else {
                    print("Connect: database connection FAIL name = NIL")
                }
            } fail: { (error) in
                
            }
        } else {
            print("Connect: There's no user saved - need to login")
            NotificationCenter.default.post(name: .NeedLogin, object: nil, userInfo: nil)
        }
    }
    
    private func isAccountEnabled(uid: String) -> Bool {
        let semasphoreValidAccount = DispatchSemaphore(value: 0)
        var isDisabled = true
        let path = "/users:\(uid):config"
        let endpoint = Endpoint.Create(to: .Firebase(.Load(path: path)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ConfigModel.AccountModel]>) in
            isDisabled = response.data?[0].disabled ?? false
            semasphoreValidAccount.signal()
        } fail: { (error) in
            isDisabled = true
            semasphoreValidAccount.signal()
        }
        
        _ = semasphoreValidAccount.wait(timeout: .distantFuture)
        if isDisabled {
            NotificationCenter.default.post(name: .ServerDisconnected, object: "Tu cuenta esta deshabilitada", userInfo: nil)
            return false
        }
        return true
    }
    
    private static func checkInternet(result: (Bool) -> ()) {
        if Reachability.sharedInstance.isConnectedToNetwork() {
            result(true)
            
        } else {
            result(false)
        }
    }
    
    @objc static func reachable() {
        print("Internet: Reachable")
    }
    
    @objc static func nonReachable() {
        print("Internet: Not Reachable")
    }
    
}

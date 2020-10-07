//
//  Connect.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

enum DisconnectReason: CaseIterable {
    case firebase
    case server
    case internet
    case invalidToken
}

extension Notification.Name {
    static let notificationConnected = Notification.Name("notificationConnected")
    static let notificationDisconnected = Notification.Name("notificationDisconnected")
}


class Connect : BaseConnect {
    static let Shared = Connect()
    
    static var fisrtTime = true
    
    static let serverEndpoint = Configuration.URL.Check.checkServer
    static let FirebaseEndpoint = Configuration.URL.Check.checkFirebase + "BodyLife:publico:conexion"
    
        
    static var timerConstantShort : TimeInterval = 2
    static var timerConstantLong : TimeInterval = 15
    static var didSentNotification = false
    static var messageString : String = ""
    
    static var isConnected : Bool? {
        didSet {
            if oldValue != isConnected {
                
                if isConnected ?? false {
                    NotificationCenter.default.post(name: .notificationConnected, object: nil)
                } else {
                    NotificationCenter.default.post(name: .notificationDisconnected, object: nil)
                }
               
            }
        }
    }
    
    static private var listenTimer : Timer?
    
    static func StartListening() {
        DispatchQueue.global().async {
            self.Start()
        }
    }
    
    static private func Start() {
        if !fisrtTime { return }
        fisrtTime = false
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.reachable), name: Notification.Name.Reachability.reachable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Connect.nonReachable), name: Notification.Name.Reachability.notReachable, object: nil)
        
        cerrarProcesoWWW()
        
        if Configuration.server == ServerType.local {
            process = MLConsoleCommand.runProcess(name: pathEnDiscoServidor, arguments: [""])
        }
        
        PeriodicChecking()
        Connect.TimerConfiguration(time: Connect.timerConstantShort)
    }
    
    static func StopListening() {
        listenTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private static func PeriodicChecking() {
        TimerConfiguration(time: timerConstantShort)
        Check { (disconnectedReason) in
            switch disconnectedReason {
            case .firebase:
                messageString = "Ups, parece que firebase está desconectado"
                isConnected = false
                break
            case .server:
                messageString = "Ups, parece que el servidor se rompió"
                isConnected = false
                break
            case .internet:
                messageString = "Ups, parece que no tenemos internet"
                isConnected = false
                break
            case .invalidToken:
                messageString = "Tienes que autenticarte"
                isConnected = false
                return
            default:
                TimerConfiguration(time: timerConstantLong)
                isConnected = true
                break
            }
            
        }
    }
    
  
    
    static private func TimerConfiguration(time: TimeInterval) {
        listenTimer?.invalidate()
        
        listenTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(PeriodicChecking), userInfo: nil, repeats: true)
    }
    
    private static func Check(notConnected: @escaping (DisconnectReason?) -> ()) {
        // INTERNET CHECK
        print("checking internet")
        var internetConnection = false
        let internetSemasphore = DispatchSemaphore(value: 0)
        checkInternet { (result) in
            internetConnection = result
            internetSemasphore.signal()
        }
        _ = internetSemasphore.wait(timeout: .distantFuture)
        if !internetConnection {
            notConnected(.internet)
            return
        }
        
        // SERVER CHECK
            print("checking server")
        var serverConnection = false
        let serverSemasphore = DispatchSemaphore(value: 0)
        checkServer { (result) in
            serverConnection = result
            serverSemasphore.signal()
        }
        _ = serverSemasphore.wait(timeout: .distantFuture)
        if !serverConnection {
            notConnected(.server)
            return
        }
 
        // FIREBASE CHECK
            print("checking firebase")
        var firebaseConnection = false
        let firebaseSemasphore = DispatchSemaphore(value: 0)
        checkFirebase { (result) in
            firebaseConnection = result
            firebaseSemasphore.signal()
        }
        _ = firebaseSemasphore.wait(timeout: .distantFuture)
            
        if !firebaseConnection {
            notConnected(.firebase)
            return
        }
        
        // USER SESSION
              print("checking user session")
        var userSessionOk = false
        let userSessionSemasphore = DispatchSemaphore(value: 0)
        
        checkUserSession { (result) in
            userSessionOk = result
            userSessionSemasphore.signal()
        }
        _ = userSessionSemasphore.wait(timeout: .distantFuture)
        
        if !userSessionOk {
            if !didSentNotification {
                didSentNotification = true
                NotificationCenter.default.post(name: .needLogin, object: nil)
            }
            notConnected(.invalidToken)
            return
        }
        
        notConnected(nil)
    }
    
    private static func checkInternet(result: (Bool) -> ()) {
        if Reachability.sharedInstance.isConnectedToNetwork() {
            result(true)
            
        } else {
            result(false)
        }
    }
    
    private static func checkServer(result: @escaping (Bool) -> ()) {
        runServerStatus(url: serverEndpoint, success: {
            result(true)
        }) {
            result(false)
            self.process?.terminate()
            self.process = MLConsoleCommand.runProcess(name: self.pathEnDiscoServidor, arguments: [""])
        }
    }
    
    private static func checkFirebase(result: @escaping (Bool) -> ()) {
        runServerStatus(url: FirebaseEndpoint, success: {
            result(true)
        }) {
             result(false)
        }
    }
    
    private static func checkUserSession(result: @escaping (Bool) -> ()) {
        ServerManager.CurrentUser { (currentUser, serverError) in
            
            if serverError != nil {
                if serverError! == ServerError.invalidToken || serverError == ServerError.tokenNotProvided {
                    if serverError! == ServerError.invalidToken {
                        print("token vencido: ", UserSaved.TokenExp()?.toString(formato: "dd-MM-yyyy HH:mm:ss") ?? "nil")
                    }
                    print("need new login:", ErrorHandler.Server(error: serverError!))
                    result(false)
                }
            } else {
                UserSaved.SaveDate(date: currentUser?.exp)
                print("token vigente: ", UserSaved.TokenExp()?.toString(formato: "dd-MM-yyyy HH:mm:ss") ?? "nil")
                result(true)
                
            }
        }
    }
    
    @objc static func reachable() {
        listenTimer?.invalidate()
        PeriodicChecking()
        TimerConfiguration(time: timerConstantShort)
    }
    
    @objc static func nonReachable() {
        listenTimer?.invalidate()
        PeriodicChecking()
        TimerConfiguration(time: timerConstantLong)
    }
    
}

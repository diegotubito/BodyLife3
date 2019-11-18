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
    
        
    static var timerConstantShort : TimeInterval = 15
    static var timerConstantLong : TimeInterval = 2
    
    static var messageString : String = ""
    
    static var isConnected : Bool? {
        didSet {
            if oldValue != isConnected {
                
                if isConnected ?? false {
                    NotificationCenter.default.post(name: .notificationConnected, object: nil)
                    TimerConfiguration(time: timerConstantLong)
                } else {
                    NotificationCenter.default.post(name: .notificationDisconnected, object: nil)
                    TimerConfiguration(time: timerConstantShort)
                }
               
            }
        }
    }
    
    static private var timer : Timer?
    
    static func ListenConnection() {
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
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private static func PeriodicChecking() {
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
            default:
                isConnected = true
                break
            }
            
        }
    }
    
  
    
    static private func TimerConfiguration(time: TimeInterval) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(PeriodicChecking), userInfo: nil, repeats: true)
    }
    
    private static func Check(notConnected: @escaping (DisconnectReason?) -> ()) {
        // INTERNET CHECK
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
        DispatchQueue.global().async {
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
    
    
      @objc static func reachable() {
        timer?.invalidate()
        PeriodicChecking()
        TimerConfiguration(time: timerConstantShort)
      }
      
    @objc static func nonReachable() {
        timer?.invalidate()
        PeriodicChecking()
        TimerConfiguration(time: timerConstantLong)
    }
    
}

//
//  Reachablility.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import SystemConfiguration
import Alamofire

extension Notification.Name {
    public struct Reachability {
        public static let reachable = Notification.Name(rawValue: "Reachability.reachable")
        public static let notReachable = Notification.Name(rawValue: "Reachability.notReachable")
    }
}

class Reachability: NSObject {
    var hasConnectionFirstTime = true
    static let sharedInstance = Reachability()
    
    public func checkConnectionFirstTime() {
        if Reachability.sharedInstance.isConnectedToNetwork() {
           hasConnectionFirstTime = true
        }
        else {
           hasConnectionFirstTime = false
        }
    }
    
    public func suscribeConnectionChanged() {
        let net = NetworkReachabilityManager()
        net?.listener = { status in
            if net?.isReachable ?? false {
                switch status {
                case .reachable(.ethernetOrWiFi):
                    self.hasConnectionFirstTime = true
                    NotificationCenter.default.post(name: Notification.Name.Reachability.reachable, object: nil)
                case .reachable(.wwan):
                    self.hasConnectionFirstTime = true
                    NotificationCenter.default.post(name: Notification.Name.Reachability.reachable, object: nil)
                case .notReachable:
                    NotificationCenter.default.post(name: Notification.Name.Reachability.notReachable, object: nil)
                case .unknown :
                    print("It is unknown whether the network is reachable")
                }
            }
            else {
                print("The network is not reachable")
                NotificationCenter.default.post(name: Notification.Name.Reachability.notReachable, object: nil)
            }
        }
        net?.startListening()
    }
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    public func isConnectedToWifi() -> Bool {
        if Reachability.sharedInstance.isConnectedToNetwork() {
            if let net = NetworkReachabilityManager() {
                if net.isReachableOnEthernetOrWiFi {
                    return true
                }
            }
        }
        
        return false
    }
}


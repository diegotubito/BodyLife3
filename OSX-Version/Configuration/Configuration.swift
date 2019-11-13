//
//  Configuration.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

struct ServerType {
    static let local = "http://127.0.0.1:3000/"
    static let keroku = "flaskdfjalskdjf/"
}

class Configuration {
    static let shared = Configuration()
      
    static var environment : String = "development"
    static var server : String = ServerType.local
    
    init() {
        Configuration.environment = (Bundle.main.infoDictionary!["ENVIRONMENT"] as! String)
    }
    
    struct URL {
        struct Database {
            static let write = "\(Configuration.server)database/v1/\(Configuration.environment)/write/"
            static let read = "\(Configuration.server)database/v1/\(Configuration.environment)/read/"
            static let transaction = "\(Configuration.server)database/v1/\(Configuration.environment)/transaction/"
            static let remove = "\(Configuration.server)database/v1/\(Configuration.environment)/remove/"
            static let update = "\(Configuration.server)database/v1/\(Configuration.environment)/update/"
            
        }
    }

}

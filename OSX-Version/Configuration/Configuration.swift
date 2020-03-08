//
//  Configuration.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

struct OperationCategory {
    static let income = "INCOME"
    static let expense = "EXPENSE"
}

struct ServerType {
    static let local = "http://127.0.0.1:3000/"
    static let keroku = "flaskdfjalskdjf/"
}

struct Paths {
    static let expenseType = "configuration:expense:type"
    static let sells = "sells"
    static let registers = "registers"
    static let payments = "payments"
    static let customerBrief = "customerBrief"
    static let customerFull = "customerFull"
    static let customerStatus = "customerStatus"
    static let fullPersonalData = "customerFull:personal"
    static let customerOriginalImage = "customer"
    static let productActivity = "product:service:activity"
    static let productDiscount = "product:service:discount"
    static let productType = "product:service:type"
    static let productService = "product:service"
    static let productArticle = "product:article"
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
            static let find = "\(Configuration.server)database/v1/\(Configuration.environment)/find/"
            static let transaction = "\(Configuration.server)database/v1/\(Configuration.environment)/transaction/"
            static let remove = "\(Configuration.server)database/v1/\(Configuration.environment)/remove/"
            static let update = "\(Configuration.server)database/v1/\(Configuration.environment)/update/"
            
        }
        
        struct Storage {
            static let upload = "\(Configuration.server)storage/v1/\(Configuration.environment)/uploadFile/"
            static let download = "\(Configuration.server)storage/v1/\(Configuration.environment)/downloadFile/"
            static let deleteFile = "\(Configuration.server)storage/v1/\(Configuration.environment)/delete/"
            
        }
        
        struct Auth {
            static let currentUser = "\(Configuration.server)auth/v1/currentUser/"
            static let login = "\(Configuration.server)auth/v1/\(Configuration.environment)/login/"
            static let refreshToken = "\(Configuration.server)auth/v1/refreshToken/"
            
        }
        
        struct Check {
            static let checkServer = "\(Configuration.server)database/v1/checkServerConnection/"
             static let checkFirebase = "\(Configuration.server)database/v1/\(Configuration.environment)/checkFirebaseConnection/"
            
        }
    }
    
}

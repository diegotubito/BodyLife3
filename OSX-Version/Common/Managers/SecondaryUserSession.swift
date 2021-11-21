//
//  SecondaryUserSession.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 09/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

struct SecondaryUserSessionModel: Codable {
    var _id : String
    var userName : String
    var password: String?
    var role : String
    var timestamp : Double
    var isEnabled : Bool
    var firstName : String?
    var lastName : String?
    var dni : String?
    var address : String?
    var phoneNumber : String?
    var token : String?
    var tokenExpiration: Double?
}

class SecondaryUserSession {
    static let shared = SecondaryUserSession()
    
    static func Save(userData: Data) {
        Keychain.set(value: userData, service: .secondaryUserData)
    }
    
    static func Remove() {
        //esto remueve todos los items en keychain
        Keychain.clear(service: .secondaryUserData)
    }
    
    static func GetUser() -> SecondaryUserSessionModel? {
        var user : SecondaryUserSessionModel?
        
        if let data = Keychain.get(service: .secondaryUserData) {
            user = try? JSONDecoder().decode(SecondaryUserSessionModel.self, from: data)
        }
        
        return user
    }
    
    static func IsLogin(result: (Bool) -> ()) {
        if GetUser() != nil {
            result(true)
            return
        }
        result(false)
    }
    
}

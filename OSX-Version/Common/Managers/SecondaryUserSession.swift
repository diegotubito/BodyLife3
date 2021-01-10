//
//  SecondaryUserSession.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 09/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

struct SecondaryUserSessionModel: Codable {
    var _id : String
    var userName : String
    var password: String
    var role : Role
    var timestamp : Double
    var isEnabled : Bool
    var firstName : String
    var lastName : String
    var dni : String
    var address : String
    var phoneNumber : String
    var token : String
    
    enum Role: String, Codable {
        case Super = "SUPER_ROLE"
        case Admin = "ADMIN_ROLE"
        case Basic = "BASIC_ROLE"
    }
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
    
    static func Update(_ newUserObj: SecondaryUserSessionModel) {
        if let data = Keychain.get(service: .secondaryUserData) {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(newUserObj.userName as Any, forKey: "userName")
            json?.updateValue(newUserObj.password as Any, forKey: "password")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            SecondaryUserSession.Save(userData: newData)
            let a = Date().time
        }
        
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
    
    static func GetUserName() -> String {
        let user = GetUser()
        
        return user?.userName ?? ""
    }
    
    static func SaveUserName(value: String) {
        var user = GetUser()
        user?.userName = value
        Update(user!)
        
    }
}

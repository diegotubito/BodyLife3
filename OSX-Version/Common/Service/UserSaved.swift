//
//  UserSessionManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Alamofire

class UserSaved {
    static let Shared = UserSaved()
    
    static func Save(userData: Data) {
        Keychain.set(value: userData, service: .userData)
    }
    
    static func Remove() {
        //esto remueve todos los items en keychain
        Keychain.clear(service: .userData)
    }
    
    static func Update(_ newUserObj: FirebaseUserModel) {
        if let data = Keychain.get(service: .userData) {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(newUserObj.token as Any, forKey: "token")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            UserSaved.Save(userData: newData)
        }
        
    }
    
    static func GetUser() -> FirebaseUserModel? {
        var user : FirebaseUserModel?
        
        if let data = Keychain.get(service: .userData) {
            user = try? JSONDecoder().decode(FirebaseUserModel.self, from: data)
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
    
    static func GetToken() -> String {
        let user = GetUser()
        
        return user?.token ?? ""
    }
    
    static func GetUID() -> String {
        let user = GetUser()
        
        return user?.uid ?? ""
    }
    
    static func TokenExp() -> Date? {
        let user = GetUser()
       
        return user?.exp?.toDate
    }
    
    static func SaveDate(date: Double?) {
        var user = GetUser()
        user?.exp = date
        Update(user!)
        
    }
}

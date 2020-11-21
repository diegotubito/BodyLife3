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
        UserDefaults.standard.set(userData, forKey: "user_session")
    }
    
    static func Remove() {
        
        UserDefaults.standard.set(nil, forKey: "user_session")
    }
    
    static func Update(_ newUserObj: FirebaseUserModel) {
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(newUserObj.token as Any, forKey: "token")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            UserSaved.Save(userData: newData)
        }
        
    }
    
    static func GetUser() -> FirebaseUserModel? {
        var user : FirebaseUserModel?
        
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
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

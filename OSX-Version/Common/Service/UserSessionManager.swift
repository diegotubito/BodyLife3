//
//  UserSessionManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Alamofire

class UserSessionManager {
    static let Shared = UserSessionManager()
    
    static func SaveUserSession(userData: Data) {
        
        UserDefaults.standard.set(userData, forKey: "user_session")
    }
    
    static func RemoveUserSession() {
        
        UserDefaults.standard.set(nil, forKey: "user_session")
    }
    
    static func UpdateUser(_ user: TokenUserModel) {
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(user.token, forKey: "token")
            json?.updateValue(user.exp as Any, forKey: "exp")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            UserSessionManager.SaveUserSession(userData: newData)
        }
        
    }
    
    static func LoadUserSession() -> FirebaseUserModel? {
        var user : FirebaseUserModel?
        
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            user = try? JSONDecoder().decode(FirebaseUserModel.self, from: data)
        }
        return user
    }
    
    static func CheckLoginStatus(result: (FirebaseUserModel?) -> ()) {
        if let user = LoadUserSession() {
            result(user)
            return
        }
        result(nil)
    }
    
    static func GetToken() -> String {
        let user = LoadUserSession()
        
        return user?.token ?? ""
    }
    
    static func GetUID() -> String {
        let user = LoadUserSession()
        
        return user?.uid ?? ""
    }
    
    static func GetTokenExpirationData() -> Date? {
        let user = LoadUserSession()
        if let fechaDouble = user?.exp {
            let date = Date(timeIntervalSince1970: fechaDouble)
            return date
        }
       return nil
    }
}

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
    
    static func updateToken(_ token: String) {
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(token, forKey: "token")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            UserSessionManager.SaveUserSession(userData: newData)
        }
        
    }
    
    static func LoadUserSession() -> UserSession? {
        var user : UserSession?
        
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            user = try? JSONDecoder().decode(UserSession.self, from: data)
        }
        return user
    }
    
    static func CheckLoginStatus(result: (UserSession?) -> ()) {
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
}

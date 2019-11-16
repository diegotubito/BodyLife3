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
        guard let dateDouble = newUserObj.exp else {
            return
        }
        
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            json?.updateValue(newUserObj.token, forKey: "token")
            json?.updateValue(dateDouble, forKey: "exp")
            let newData = (try? JSONSerialization.data(withJSONObject: json!, options: []))!
            UserSaved.Save(userData: newData)
        }
        
    }
    
    static func Load() -> FirebaseUserModel? {
        var user : FirebaseUserModel?
        
        if let data = UserDefaults.standard.object(forKey: "user_session") as? Data {
            user = try? JSONDecoder().decode(FirebaseUserModel.self, from: data)
        }
        return user
    }
    
    static func IsLogin(result: (Bool) -> ()) {
        if Load() != nil {
            result(true)
            return
        }
        result(false)
    }
    
    static func GetToken() -> String {
        let user = Load()
        
        return user?.token ?? ""
    }
    
    static func GetUID() -> String {
        let user = Load()
        
        return user?.uid ?? ""
    }
    
    static func TokenExp() -> Date? {
        let user = Load()
       
        return user?.exp?.toDate()
    }
    
    static func SaveDate(date: Double?) {
        var user = Load()
        user?.exp = date
        Update(user!)
        
    }
}

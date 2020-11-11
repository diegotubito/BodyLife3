//
//  ServerManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 15/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa
import BLServerManager

class ServerManager {
    static let uid = UserSaved.GetUser()?.uid
    
    static let Shared = ServerManager()
    
//    static func LoadStock(completion: @escaping (Data?, Error?)->()) {
//        let basicUrl = BLEndpoint.URL.Firebase.database
//        let url = basicUrl + "/users:\(uid!):\(Paths.productArticle)"
//        let _services = NetwordManager()
//        
//        _services.get(url: url) { (data, error) in
//            guard error == nil else {
//                completion(nil, error)
//                return
//            }
//            
//            completion(data, nil)
//        }
//    }
//    
    
    static func Remove(path: String, completion: @escaping (Data?, ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.remove
        let url = basicUrl + "users:\(uid!):" + path
        
        let _services = NetwordManager()
        _services.post(url: url, body: nil) { (data, error) in
            completion(data, error)
        }
        
    }
    
    static func Update(path: String, json: [String: Any], completion: @escaping (Data?, ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.update
        let url = basicUrl + "users:\(uid!):" + path
        
        let _services = NetwordManager()
        _services.post(url: url, body: json) { (data, error) in
            completion(data, error)
        }
        
    }
   
   
    static func CurrentUser(completion: @escaping (CurrentUserModel?, ServerError?) -> Void) {
        let url = BLEndpoint.URL.Firebase.currentUser
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let currentUser = try JSONDecoder().decode(CurrentUserModel.self, from: data)
                
                completion(currentUser, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
                return
            }
        }
    }
    
    static func ConntectMongoDB(uid: String, success: @escaping (Bool) -> ()) {
        let url = "\(BLEndpoint.URL.Server.ConnectMongodb)?database=\(uid)"
        
        let _service = NetwordManager()
        _service.post(url: url, body: nil) { (data, serverError) in
            guard data != nil else {
                success(false)
                return
            }
            success(true)
        }
    }
    
    static func DisconnectMongoDB(success: @escaping (Bool) -> ()) {
        let url = BLEndpoint.URL.Server.DisconnectMongodb
        
        let _service = NetwordManager()
        _service.post(url: url, body: nil) { (data, serverError) in
            guard data != nil else {
                success(false)
                return
            }
            success(true)
        }
    }
}


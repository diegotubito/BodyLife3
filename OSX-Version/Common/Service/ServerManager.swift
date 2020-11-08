//
//  ServerManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 15/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa

class ServerManager {
    static let uid = UserSaved.GetUser()?.uid
    
    static let Shared = ServerManager()
    
    static func CheckServerConnection(success: @escaping (Bool) -> ()) {
        let url = Config.URL.Server.CheckServerConnection
        let _services = NetwordManager()
        _services.get(url: url) { (data, error) in
            guard data != nil else {
                success(false)
                return
            }
            
            success(true)
        }
    }
    
    static func Transaction(path: String, key: String, value: Double, success: @escaping ()->(), fail: @escaping (ServerError?) -> Void) {
        let basicUrl = Config.URL.Firebase.transaction
        let url = basicUrl + "/users:\(uid!):\(path):\(key)"
        let _services = NetwordManager()
        
        let body = ["transaction": value]
        
        _services.post(url: url, body: body) { (data, error) in
            guard error == nil else {
                fail(error)
                return
            }
            success()
        }
    }
    
    static func LoadStock(completion: @escaping (Data?, Error?)->()) {
        let basicUrl = Config.URL.Firebase.database
        let url = basicUrl + "/users:\(uid!):article"
        let _services = NetwordManager()
        
        _services.get(url: url) { (data, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
    }
    
    
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
    
    static func Read<T:Decodable>(path: String, completion: @escaping (T?, ServerError?) -> ()) {
        let basicUrl = Configuration.URL.Database.read
        let url = basicUrl + "users:\(uid!):" + path
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let dataParsered = try JSONDecoder().decode(T.self, from: data)
                completion(dataParsered, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
                return
            }
        }
    }
   
    static func CurrentUser(completion: @escaping (CurrentUserModel?, ServerError?) -> Void) {
        let url = Config.URL.Firebase.currentUser
        
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
    
    static func RefreshToken(completion: @escaping (CurrentUserModel?, ServerError?) -> ()) {
        let loginJSON = ["email"      : ""] as [String : Any]
        
        let url = Config.URL.Server.RefreshToken
        
        //HTTP Headers
        
        let _service = NetwordManager()
        _service.post(url: url, body: loginJSON) { (data, serverError) in
            
            guard let data = data else {
                completion(nil, serverError)
                return
            }
            do {
                
                let tokenUserDecoded = try JSONDecoder().decode(CurrentUserModel.self, from: data)
                completion(tokenUserDecoded, nil)
            } catch {
                completion(nil, error as? ServerError)
            }
        }
    }
    
    static func ConntectMongoDB(uid: String, success: @escaping (Bool) -> ()) {
        let url = "\(Config.URL.Server.ConnectMongodb)?database=\(uid)"
        
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
        let url = Config.URL.Server.DisconnectMongodb
        
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


//
//  Worker.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 11/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

class WorkerServer {
    static let Shared = WorkerServer()
    
    static func PostToDatabase<T:Decodable>(path: String, Request: PostRequest, completion: @escaping (T?, ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.write
        
        let url = basicUrl + path
        let _services = NetwordManager()
        
        _services.post(url: url, body: Request.json) { (data, error) in
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
    
    static func Transaction(path: String, key: String, value: Int, success: @escaping ()->(), fail: @escaping (ServerError?) -> Void) {
        let basicUrl = Configuration.URL.Database.transaction
        let url = basicUrl + path + ":" + key
        let _services = NetwordManager()
        
        let body = ["valor": value]
        
        _services.post(url: url, body: body) { (data, error) in
            guard error == nil else {
                fail(error)
                return
            }
            success()
        }
    }
    
    static func DeleteDataBase(path: String, completion: @escaping (Data?, ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.remove
        let url = basicUrl + path
        
        let _services = NetwordManager()
        _services.post(url: url, body: nil) { (data, error) in
            completion(data, error)
        }
        
    }
    
    static func UpdateDataBase(path: String, json: [String: Any], completion: @escaping (Data?, ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.update
        let url = basicUrl + path
        
        let _services = NetwordManager()
        _services.post(url: url, body: json) { (data, error) in
            completion(data, error)
        }
        
    }
    
    static func Read<T:Decodable>(path: String, completion: @escaping (T?, ServerError?) -> Void) {
        let basicUrl = Configuration.URL.Database.read
        let url = basicUrl + path
        
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
    
    static func GetCurrentUser(completion: @escaping (TokenUserModel?, ServerError?) -> Void) {
        let basicUrl = Configuration.URL.Auth.currentUser
        let url = basicUrl
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let dataParsered = try JSONDecoder().decode(TokenUserModel.self, from: data)
                completion(dataParsered, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
                return
            }
        }
    }
    
    
    
     static func CurrentUser(completion: @escaping (TokenUserModel?, ServerError?) -> ()) {
        let url = "http://127.0.0.1:3000/auth/v1/currentUser"
        //HTTP Headers
        
        let _service = NetwordManager()
      
        _service.get(url: url) { (data, serverError) in
            
            guard let data = data else {
                completion(nil, serverError)
                return
            }
            do {
                let tokenUserDecoded = try JSONDecoder().decode(TokenUserModel.self, from: data)
                completion(tokenUserDecoded, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
            }
        }
    }
    
    static func RefreshToken(completion: @escaping (TokenUserModel?, ServerError?) -> ()) {
        let loginJSON = ["email"      : ""] as [String : Any]
          
          let url = "http://127.0.0.1:3000/auth/v1/development/refreshToken"
          //HTTP Headers
          
          let _service = NetwordManager()
          _service.post(url: url, body: loginJSON) { (data, serverError) in
             
            guard let data = data else {
                completion(nil, serverError)
                return
            }
            do {
            
                let tokenUserDecoded = try JSONDecoder().decode(TokenUserModel.self, from: data)
                UserSessionManager.UpdateUser(tokenUserDecoded)
                completion(tokenUserDecoded, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
            }
          }
      }
      
   
}

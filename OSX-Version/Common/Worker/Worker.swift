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
   
}

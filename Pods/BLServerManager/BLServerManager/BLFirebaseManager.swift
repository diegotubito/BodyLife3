//
//  BLFirebaseManager.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 07/11/2020.
//

import Foundation
import Cocoa

public class BLFirebaseManager {
    private init () {}
  /*
    static func Transaction(request: BLServerRequestModel, success: @escaping ()->(), fail: @escaping (ServerError?) -> Void) {
        let url = url + "/users:\(uid):\(path):\(key)"
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
    
    static func LoadStock(uid: String, url: String, completion: @escaping (Data?, Error?)->()) {
        let completeUrl = url + "/users:\(uid):article"
        let _services = NetwordManager()
        
        _services.get(url: completeUrl) { (data, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
    }
    
    
    static func Remove(uid: String, url: String, path: String, completion: @escaping (Data?, ServerError?) -> Void) {
        
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
    */
}

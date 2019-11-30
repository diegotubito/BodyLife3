//
//  ServerManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 15/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa

class ServerManager {
    static let uid = UserSaved.Load()?.uid
            
    static let Shared = ServerManager()
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
      
    
    static func jsonArray(json: [String: Any]) -> [[String: Any]] {
        var result = [[String : Any]]()
        
        for (key, value) in json {
            if let aux = value as? [String : Any] {
                var aux2 = aux
                aux2["key"] = key
                result.append(aux2)
            }
        }
        
        return result
    }
    
    static func Post(path: String, Request: NewCustomer.NewCustomer.Request, onError: @escaping (ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.write
        
        let url = basicUrl + "users:\(uid!):" + path
        let _services = NetwordManager()
        
        _services.post(url: url, body: Request.json) { (data, error) in
            guard data != nil else {
                onError(error)
                return
            }
          
            onError(nil)
        }
        
    }
    
    static func Post(path: String, json: [String : Any], onError: @escaping (ServerError?) -> Void) {
        
        let basicUrl = Configuration.URL.Database.write
        
        let url = basicUrl + "users:\(uid!):" + path
        let _services = NetwordManager()
        
        _services.post(url: url, body: json) { (data, error) in
            guard data != nil else {
                onError(error)
                return
            }
          
            onError(nil)
        }
        
    }
    
    static func Transaction(path: String, key: String, value: Int, success: @escaping ()->(), fail: @escaping (ServerError?) -> Void) {
        let basicUrl = Configuration.URL.Database.transaction
        let url = basicUrl + "users:\(uid!):" + path + ":" + key
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
    
    static func FindByKey(path: String, key: String, value: String, completion: @escaping ([[String: Any]]?, ServerError?) -> ()) {
        let basicUrl = Configuration.URL.Database.find
        let url = basicUrl + "\(key)/\(value)/" + "users:\(uid!):" + path
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
               
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                let array = jsonArray(json: json)
                completion(array, nil)
            } catch {
                completion(nil, ServerError.body_serialization_error)
                return
            }
        }
        
    }
    
    static func ReadAll(path: String, completion: @escaping ([[String: Any]]?, ServerError?) -> ()) {
        let basicUrl = Configuration.URL.Database.read
        if uid == nil {return}
        let url = basicUrl + "users:\(uid!):" + path
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
               
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                let array = jsonArray(json: json)
                completion(array, nil)
            } catch {
                completion([[:]], nil)
                return
            }
        }
        
    }
    
    static func ReadJSON(path: String, completion: @escaping ([String: Any]?, ServerError?) -> ()) {
           let basicUrl = Configuration.URL.Database.read
           let url = basicUrl + "users:\(uid!):" + path
           
           let _service = NetwordManager()
           _service.get(url: url) { (data, error) in
               guard let data = data else {
                   completion(nil, error)
                   return
               }
               do {
                  
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                   completion(json, nil)
               } catch {
                   completion(nil, ServerError.body_serialization_error)
                   return
               }
           }
           
       }
    
    static func CurrentUser(completion: @escaping (CurrentUserModel?, ServerError?) -> Void) {
        let basicUrl = Configuration.URL.Auth.currentUser
        let url = basicUrl
        
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
    
    static func RefreshToken(onError: @escaping (ServerError?) -> ()) {
        let loginJSON = ["email"      : ""] as [String : Any]
          
          let url = Configuration.URL.Auth.refreshToken
              
          //HTTP Headers
          
          let _service = NetwordManager()
          _service.post(url: url, body: loginJSON) { (data, serverError) in
             
            guard let data = data else {
                onError(serverError)
                return
            }
            do {
            
                let tokenUserDecoded = try JSONDecoder().decode(CurrentUserModel.self, from: data)
                var user = UserSaved.Load()
                user?.token = tokenUserDecoded.token
                user?.exp = tokenUserDecoded.exp
                
                UserSaved.Update(user!)
                onError(nil)
            } catch {
                onError(error as? ServerError)
            }
        }
    }
    
    static func Login(userName: String, password: String, response: @escaping (Data?, ServerError?) -> Void) {
        
        let body = ["email"      : userName,
                    "password"   : password] as [String : Any]
        let url = Configuration.URL.Auth.login
        
        
        let _service = NetwordManager()
        _service.post(url: url, body: body) { (data, error) in
            guard error == nil else {
                response(nil, error)
                return
            }
            
            response(data, nil)
            
        }
    }
    
    
    static func DownloadPicture(path: String, completion: @escaping (NSImage?, ServerError?) -> ()) {
       
        let basicUrl = Configuration.URL.Storage.download
        let uidPath = "users:\(uid!):"
        let url = basicUrl + uidPath + path
        
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            print("loaded from cache")
            completion(imageFromCache, nil)
            return
            
        }
        
        
        let _service = NetwordManager()
        _service.get(url: url) { (imageData, error) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            if imageData != nil {
                if let image = NSImage(data: imageData!) {
                    completion(image, nil)
                        
                    
                    DispatchQueue.main.async {
                        //save loaded image to cache for better performance
                        print("saved to cache")
                        let imageToCache = image
                        self.imageCache.setObject(imageToCache, forKey: url as AnyObject)
                        completion(imageToCache, nil)
                        return
                        
                    }
                    return
                }
            }
            completion(nil, error)
        }
        
    }
    
    
}


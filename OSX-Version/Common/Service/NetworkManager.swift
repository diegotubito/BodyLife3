//
//  NetworkManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Foundation
import Cocoa
import Alamofire

class NetwordManager {
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    
    func post(url: String, body: [String : Any]?, response: @escaping (Data?, ServerError?) -> Void) {
        //create the url with NSURL
        let urlTransformmed = URL(string: url)!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: urlTransformmed)
        request.httpMethod = "POST" //set http method as POST
        
        //declare parameter as a dictionary which contains string as key and value combination.
        if let parameters = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
            } catch {
                response(nil, ServerError.body_serialization_error)
                return
            }
        }
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(UserSessionManager.GetToken(), forHTTPHeaderField: "x-access-token")
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, res, error in
            guard error == nil else {
                response(nil, ServerError.server_error)
                return
            }
            
            if let httpResponse = res as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    response(data, nil)
                } else if httpResponse.statusCode == 401 {
                    response(nil, ServerError.invalidToken)
                } else if httpResponse.statusCode == 403 {
                    response(nil, ServerError.tokenNotProvided)
                } else if httpResponse.statusCode == 501 {
                    response(nil, ServerError.firebase_connection_error)
                } else if httpResponse.statusCode == 404 {
                    response(nil, ServerError.notFound)
                } else if httpResponse.statusCode == 500 {
                    response(nil, ServerError.error500)
                } else {
                    response(nil, ServerError.unknown_error)
                }
            }
        })
        task.resume()
    }
    
    func get(url: String, response: @escaping(Data?, ServerError?) -> Void){
        //create the url with NSURL
        let urlTransformmed = URL(string: url)!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: urlTransformmed)
        request.httpMethod = "GET" //set http method as POST
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(UserSessionManager.GetToken(), forHTTPHeaderField: "x-access-token")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, res, error -> Void in
            
            guard error == nil else {
                response(nil, ServerError.server_error)
                return
            }
            
            if let httpResponse = res as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    response(data, nil)
                } else if httpResponse.statusCode == 401 {
                    response(nil, ServerError.invalidToken)
                } else if httpResponse.statusCode == 403 {
                    response(nil, ServerError.tokenNotProvided)
                } else if httpResponse.statusCode == 501 {
                    response(nil, ServerError.firebase_connection_error)
                } else if httpResponse.statusCode == 404 {
                    response(nil, ServerError.notFound)
                } else {
                    response(nil, ServerError.unknown_error)
                }
            }
            
        })
        task.resume()
    }
    
    func downloadImageFromUrl(url: String, result: @escaping (NSImage?) -> Void, fail: @escaping (ServerError?) -> Void) {
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            print("loaded from cache")
            result(imageFromCache)
            return
            
        }
        
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: url)!) { (
            data, response, error) -> Void in
            guard error == nil else {
                fail(error as? ServerError)
                return
            }
            
            guard let data = data, let image = NSImage(data: data) else {
                fail(ServerError.emptyData)
                return
            }
            
            DispatchQueue.main.async {
                //save loaded image to cache for better performance
                let imageToCache = image
                self.imageCache.setObject(imageToCache, forKey: url as AnyObject)
                result(imageToCache)
                return
                
            }
            
            
        }
        dataTask.resume()
        
    }
    
    
    func cargarFoto(path: String, completion: @escaping (Data?, Error?) -> Void) {
        let accion = "http://127.0.0.1:3000/storage/v1/principal/downloadFile/"
        
        let url = URL(string: accion + path)
        
        Alamofire.request(url!).responseData { (response) in
            
            switch(response.result) {
                
            case .success(_):
                
                if response.result.value != nil{
                    if let data = response.data {
                        if NSImage(data: data) != nil {
                            completion(data, response.result.error)
                            return
                        }
                    }
                }
                completion(nil, response.result.error)
                break
                
            case .failure(_):
                completion(nil, response.result.error)
                //  print(response.result.error ?? "error de lectura")
                break
                
            }
            
            
        }
        
    }
    
}


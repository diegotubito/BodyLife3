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
        request.addValue(UserSaved.GetToken(), forHTTPHeaderField: "x-access-token")
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
                } else if httpResponse.statusCode == 400 {
                    //Login Auth Error Codes
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                        let code = json["code"] as? String
                        
                        switch code {
                        case "auth/wrong-password":
                            response(nil, ServerError.auth_wrong_password)
                            break
                        case "auth/too-many-requests":
                            response(nil, ServerError.auth_too_many_wrong_password)
                            break
                        case "auth/invalid-email" :
                            response(nil, ServerError.auth_invalid_email)
                            break
                        case "auth/user-not-found" :
                            response(nil, ServerError.auth_user_not_found)
                            break
                            
                        default:
                            response(nil, ServerError.unknown_auth_error)
                            break
                        }
                        
                        
                    } catch {
                        response(nil, ServerError.body_serialization_error)
                    }
                     
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
        var session = URLSession.shared
      
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 15.0
        session = URLSession(configuration: sessionConfig)
        
          
        //now create the Request object using the url object
        var request = URLRequest(url: urlTransformmed)
        request.httpMethod = "GET" //set http method as POST
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(UserSaved.GetToken(), forHTTPHeaderField: "x-access-token")
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, res, error -> Void in
            
            guard error == nil else {
                response(nil, ServerError.server_error)
                return
            }
            
            if let httpResponse = res as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    response(data, error as? ServerError)
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
    
    
    func downloadPhoto(path: String, completion: @escaping (Data?, Error?) -> Void) {
        let accion : String = Configuration.URL.Storage.download
        
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
    
    func uploadPhoto(path: String, imageData: Data, nombre: String, tipo: String, completion:@escaping ([String : Any]?, ServerError?) -> Void ) {
        let baseURL = Configuration.URL.Storage.upload
        let url = URL(string: baseURL + path)
        
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                    "x-access-token" : UserSaved.GetToken()]
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "image", fileName: nombre + "." + tipo, mimeType: "image/jpeg")
        }, usingThreshold: UInt64.init(), to: url!, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("upload progress: ", Progress.fractionCompleted)
                })
                upload.responseJSON { response in
                    
                    let json = response.result.value as? [String : Any]
                    
                    if let httpResponse = response.response {
                        if httpResponse.statusCode == 200 {
                            completion(json, nil)
                        } else if httpResponse.statusCode == 401 {
                            completion(nil, ServerError.invalidToken)
                        } else if httpResponse.statusCode == 403 {
                            completion(nil, ServerError.tokenNotProvided)
                        } else if httpResponse.statusCode == 501 {
                            completion(nil, ServerError.firebase_connection_error)
                        } else if httpResponse.statusCode == 404 {
                            completion(nil, ServerError.notFound)
                        } else {
                            completion(nil, ServerError.unknown_error)
                        }
                    }
                }
            case .failure(let error):
                completion(nil, error as? ServerError)
                print("Error in upload:", error.localizedDescription)
                break
            }
            
        }
    }
    
}


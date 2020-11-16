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
import BLServerManager

class StorageManager {
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    func uploadPhoto(path: String, imageData: Data, nombre: String, tipo: String, completion:@escaping ([String : Any]?, ServerError?) -> Void ) {
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/uploadImage/\(path)"
        
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                    "x-access-token" : UserSaved.GetToken()]
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "image", fileName: nombre + "." + tipo, mimeType: "image/jpeg")
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            
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


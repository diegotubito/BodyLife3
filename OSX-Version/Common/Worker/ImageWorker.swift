//
//  Image.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 16/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager
import Alamofire

public class CommonWorker {
    
    public struct Image {
        static var imageCache = NSCache<AnyObject, AnyObject>()
        
        static func loadThumbnail(row: Int, customer: CustomerModel.Customer, completion: @escaping (NSImage?, Int) -> ()) {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail?uid=\(customer.uid)"
            
            //if I have already loaded the image, there's no need to load it again.
            if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
                //return the image previously loaded
                completion(imageFromCache, row)
                return
            }
            
            let uid = customer._id
            let endpoint = Endpoint.Create(to: .Image(.LoadThumbnail(_id: uid!)))
            BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<ThumbnailModel.Thumbnail>) in
                guard let imageDowloaded = response.data else {
                    completion(nil, row)
                    return
                }
                let image = imageDowloaded.thumbnailImage.convertToImage
                self.imageCache.setObject(image!, forKey: url as AnyObject)
                completion(image, row)
            } fail: { (error) in
                completion(nil, row)
            }
        }
        
        static func downloadBigSize(childID: String, completion: @escaping (NSImage?, Error?) -> ()) {
            let key = childID
            
            //if I have already loaded the image, there's no need to load it again.
            if let imageFromCache = imageCache.object(forKey: key as AnyObject) as? NSImage {
                //return the image previously loaded
                print("image loaded from cached")
                completion(imageFromCache, nil)
                return
            }
            
            let userUID = MainUserSession.GetUID()
            let endpoint = Endpoint.Create(to: .Image(.LoadBigSize(userUID: userUID, customerUID: childID)))
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                guard let data = data, let image = NSImage(data: data) else {
                    completion(nil, nil)
                    return
                }
                self.imageCache.setObject(image, forKey: key as AnyObject)
                completion(image, nil)
            } fail: { (error) in
                completion(nil, error)
            }
            
        }
        
        
        public static func uploadThumbnail(_id: String, image: NSImage, success: @escaping (Bool) -> ()) {
            guard let imageCropped = image.crop(size: NSSize(width: ImageSize.thumbnail, height: ImageSize.thumbnail)),
                  let thumbnail = imageCropped.convertToBase64 else {
                success(false)
                return
            }
            
            if thumbnail.isEmpty {
                success(false)
                return
            }
            
            let body = ["_id": _id,
                        "thumbnailImage": thumbnail,
                        "isEnabled" : true] as [String : Any]
            
            let endpoint = Endpoint.Create(to: .Image(.SaveThumbnail(body: body)))
            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                success(true)
            } fail: { (error) in
                success(false)
            }
            
        }
        
        public static func updateThumbnail(_id: String, image: NSImage, stringImage: @escaping (String?) -> ()) {
            guard let imageCropped = image.crop(size: NSSize(width: 50, height: 50)),
                  let thumbnail = imageCropped.convertToBase64 else {
                stringImage(nil)
                return
            }
            
            if thumbnail.isEmpty {
                stringImage(nil)
                return
            }
            
            let body = ["_id": _id,
                        "thumbnailImage": thumbnail,
                        "isEnabled" : true] as [String : Any]
            
            let endpoint = Endpoint.Create(to: .Image(.UpdateThumbnail(body: body)))
            BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<ThumbnailModel.Thumbnail>) in
                stringImage(response.data?.thumbnailImage)
            } fail: { (error) in
                stringImage(nil)
            }
        }
 
        static func uploadImage(uid: String, image: NSImage, success: @escaping (Bool) -> ()) {
            let userId = UserSession?.uid ?? ""
            let pathImage = "\(userId):customer"
            if let imageData = image.tiffRepresentation {
                uploadPhoto(path: pathImage, imageData: imageData, nombre: uid, tipo: "jpeg") { (jsonResponse, error) in
                    if jsonResponse != nil {
                        self.imageCache.setObject(image, forKey: uid as AnyObject)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            success(true)
                        }
                    } else {
                        success(false)
                    }
                }
            }
        }
        
        static func uploadPhoto(path: String, imageData: Data, nombre: String, tipo: String, completion:@escaping ([String : Any]?, ServerError?) -> Void ) {
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/uploadImage/\(path)"
            
            let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                        "x-access-token" : MainUserSession.GetToken()]
            
            
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
}

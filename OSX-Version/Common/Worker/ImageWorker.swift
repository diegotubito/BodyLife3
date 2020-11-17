//
//  Image.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 16/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

public class CommonWorker {
    
    public struct Image {
        public static func uploadThumbnail(_id: String, image: NSImage, success: @escaping (Bool) -> ()) {
            guard let imageCropped = image.crop(size: NSSize(width: 50, height: 50)),
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

            
            
//            BLServerManager.ApiCall(endpoint: endpoint) { (data) in
//                success(true)
//            } fail: { (error) in
//                success(false)
//            }
            
        }
 
        static func uploadImage(uid: String, image: NSImage, success: @escaping (Bool) -> ()) {
            let userId = UserSession?.uid ?? ""
            let pathImage = "\(userId):customer"
            let net = StorageManager()
            if let imageData = image.tiffRepresentation {
                net.uploadPhoto(path: pathImage, imageData: imageData, nombre: uid, tipo: "jpeg") { (jsonResponse, error) in
                    if jsonResponse != nil {
                        success(true)
                    } else {
                        success(false)
                    }
                }
            }
        }
    }
}

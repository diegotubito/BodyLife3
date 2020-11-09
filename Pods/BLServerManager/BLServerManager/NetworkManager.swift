//
//  NetworkManager.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 07/11/2020.
//
import Cocoa

class NetwordManager {
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    private init() {}
    
    static func request(endpoint: BLEndpointModel, completion: @escaping (Result<Data, BLNetworkError>) -> ()) {
       
        guard let url = URL(string: endpoint.url + (endpoint.query ?? "")) else {
            completion(.failure(BLNetworkError.wrongUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        if endpoint.body != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: endpoint.body ?? [:], options: .prettyPrinted)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(endpoint.token ?? "", forHTTPHeaderField: "x-access-token")
        
        var session = URLSession.shared
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 20
        session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, res, error in
            
            guard error == nil else {
                completion(.failure(error as? BLNetworkError ?? .unknown_error))
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                completion(.failure(BLNetworkError.unknown_error))
                return
            }
            
            if let errorHandler = self.ErrorHandler(httpResponse: httpResponse) {
                completion(.failure(errorHandler))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown_error))
                return
            }
            
            completion(.success(data))
        })
        task.resume()
        
    }
    
    private static func ErrorHandler(httpResponse: HTTPURLResponse) -> BLNetworkError? {
        if httpResponse.statusCode == 200 {
            return nil
        } else if httpResponse.statusCode == 401 {
            return BLNetworkError.invalidToken
        } else if httpResponse.statusCode == 403 {
            return BLNetworkError.tokenNotProvided
        } else if httpResponse.statusCode == 404 {
            return BLNetworkError.notFound
        } else if httpResponse.statusCode == 500 {
            return BLNetworkError.server_error
        } else if httpResponse.statusCode == 400 {
            return BLNetworkError.badRequest
        } else {
            return BLNetworkError.unknown_error
        }
    }
    
    /*
    func downloadImageFromUrl(url: String, result: @escaping (NSImage?) -> Void, fail: @escaping (ServerError?) -> Void) -> URLSessionDataTask? {
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            result(imageFromCache)
            return nil
            
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
            
            //save loaded image to cache for better performance
            let imageToCache = image
            self.imageCache.setObject(imageToCache, forKey: url as AnyObject)
            result(imageToCache)
            
            
            
            
        }
        dataTask.resume()
        return dataTask
    }
    
    func uploadPhoto(path: String, imageData: Data, nombre: String, tipo: String, completion:@escaping ([String : Any]?, ServerError?) -> Void ) {
        let url = "\(Config.baseUrl.rawValue)/v1/uploadImage/\(path)"
        
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
    */
}

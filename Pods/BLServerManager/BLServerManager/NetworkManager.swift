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
        sessionConfig.timeoutIntervalForRequest = 40
        sessionConfig.timeoutIntervalForResource = 40
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
}

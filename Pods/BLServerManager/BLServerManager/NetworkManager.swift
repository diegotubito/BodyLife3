//
//  NetworkManager.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 07/11/2020.
//

/*
 #if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
*/

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
        request.addValue(endpoint.tokenSecondaryUser ?? "", forHTTPHeaderField: "x-access-token-secondary-user")
        
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
            
            guard let data = data else {
                completion(.failure(.unknown_error))
                return
            }
            
            completion(.success(data))
        })
        task.resume()
        
    }
}

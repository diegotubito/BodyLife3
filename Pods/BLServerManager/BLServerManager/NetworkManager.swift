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
    typealias DataTaskResult = ((Data?, String?))
    
    static func request(endpoint: BLEndpointModel, completion: @escaping (DataTaskResult) -> ()) {
        
        guard let url = URL(string: endpoint.url + (endpoint.query ?? "")) else {
            completion((nil, "wrong URL format = \(endpoint.url)"))
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
                debugLog(error?.localizedDescription ?? "unknown error")
                completion((nil, error?.localizedDescription))
                return
            }
            
            guard let data = data else {
                debugLog("Empty data")
                completion((nil, "empty data"))
                return
            }
            
            let response = res as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let message : String = (json?["errorMessage"] as? String) ?? "error code \(status)"
                debugLog(message)
                completion((nil, message))
                return
            }
   
            completion((data, nil))
        })
        task.resume()
        
    }
}


func debugLog(_ message: String) {
    print("💔💔💔💔💔💔💔")
    print(message)
    print("---------------")
}

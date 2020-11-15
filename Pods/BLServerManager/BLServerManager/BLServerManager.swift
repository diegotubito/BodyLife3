//
//  BLServerManager.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 06/11/2020.
//

import Foundation

public class BLServerManager {
    public static var baseUrl : BLServer!
    
    private init () {}
    
    public static func ApiCall<T: Decodable>(endpoint: BLEndpointModel, success: @escaping (T) -> (), fail: @escaping (BLNetworkError) ->()) {
        
        self.ApiRequest(endpoint: endpoint) { (result) in
            switch result {
            case .failure(let error):
                fail(error)
                break
            case .success(let data):
                do {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    let genericData = try JSONDecoder().decode(T.self, from: data)
                    success(genericData)
                } catch {
                    fail(.serializationError)
                }
                break
            }
        }
    }
    
    private static func ApiRequest(endpoint: BLEndpointModel, completion: @escaping (Result<Data, BLNetworkError>) -> ()) {
        NetwordManager.request(endpoint: endpoint) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                break
            case .success(let data):
                completion(.success(data))
                break
            }
        }
    }
    
}

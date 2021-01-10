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
                    let genericData = try JSONDecoder().decode(T.self, from: data)
                    success(genericData)
                } catch {
                    fail(.serializationError)
                }
                break
            }
        }
    }
    
    public static func ApiCall(endpoint: BLEndpointModel, success: @escaping (Data?) -> (), fail: @escaping (BLNetworkError) ->()) {
        
        self.ApiRequest(endpoint: endpoint) { (result) in
            switch result {
            case .failure(let error):
                fail(error)
                break
            case .success(let data):
                success(data)
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


public class BLServerManagerBeta {
    public static var baseUrl : BLServer!
    
    private init () {}
    
    public static func ApiCall<T: Decodable>(endpoint: BLEndpointModel, success: @escaping (T) -> (), fail: @escaping (String) ->()) {
        
        self.ApiRequest(endpoint: endpoint) { (data) in
            do {
                let genericData = try JSONDecoder().decode(T.self, from: data)
                success(genericData)
            } catch {
                fail(BLNetworkError.serializationError.rawValue)
            }
        } fail: { (message) in
            fail(message)
        }
    }
    
    public static func ApiCall(endpoint: BLEndpointModel, success: @escaping (Data?) -> (), fail: @escaping (String) ->()) {
        
        self.ApiRequest(endpoint: endpoint) { (data) in
            success(data)
        } fail: { (message) in
            fail(message)
        }
    }
    
    
    private static func ApiRequest(endpoint: BLEndpointModel, success: @escaping (Data) -> (), fail: @escaping (String) -> ()) {
        NetwordManagerBeta.request(endpoint: endpoint) { (result) in
            switch result {
            case .failure(let error):
                fail(error.localizedDescription)
                break
            case .success(let data):
                let errorModel = try? JSONDecoder().decode(BLErrorModel.self, from: data)
                if let message = errorModel?.errorMessage {
                    fail(message)
                    return
                }
                
                success(data)
                break
            }
        }
    }
}




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
    
    public static func EndpointValue(to: BLEndpointType) -> BLEndpointModel {
        
        switch to {
        case .RefreshToken:
            return BLEndpointModel(url: BLEndpoint.URL.Server.RefreshToken,
                                         token: nil,
                                         method: "POST",
                                         query: nil)
        case .GetAllPeriod:
            return BLEndpointModel(url: BLEndpoint.URL.period,
                                         token: nil,
                                         method: "GET",
                                         query: nil)
        case .GetAllDiscount:
            return BLEndpointModel(url: BLEndpoint.URL.discount,
                                         token: nil,
                                         method: "GET",
                                         query: nil)
        case .SaveNewSell(let token, let body):
            return BLEndpointModel(url: BLEndpoint.URL.sell,
                                         token: token,
                                         method: "POST",
                                         query: nil,
                                         body: body)
        case .CheckServerConnection:
            return BLEndpointModel(url: BLEndpoint.URL.Server.CheckServerConnection, token: nil, method: "GET", query: nil, body: nil)
        case .Transaction(uid: let uid, path: let path, key: let key, value: let value):
            let body = ["transaction": value]
            let url = BLEndpoint.URL.Firebase.transaction + "/users:\(uid):\(path):\(key)"
            return BLEndpointModel(url: url,
                                   token: nil,
                                   method: "POST",
                                   query: nil,
                                   body: body)
        case .Stock(uid: let uid, path: let path):
            let url = BLEndpoint.URL.Firebase.database + "/users:\(uid):\(path)"
            return BLEndpointModel(url: url,
                                   token: nil,
                                   method: "GET",
                                   query: nil,
                                   body: nil)
        case .ConnectToMongoDB(query: let query):
            let url = "\(BLEndpoint.URL.Server.ConnectMongodb)"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: query, body: nil)
        case .DisconnectMongoDB:
            let url = BLEndpoint.URL.Server.DisconnectMongodb
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: nil)
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

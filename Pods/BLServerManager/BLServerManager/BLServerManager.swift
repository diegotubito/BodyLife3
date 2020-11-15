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
    
    public static func EndpointValue(to: BLEndpointType) -> BLEndpointModel {
        
        switch to {
        case .RefreshToken(body: let body):
            return BLEndpointModel(url: BLEndpoint.URL.Server.RefreshToken,
                                   token: nil,
                                   method: "POST",
                                   query: nil,
                                   body: body)
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
        case .Sell(.Save(body: let body, token: let token)):
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
        case .Payment(.Delete(uid: let uid)) :
            let query = "?id=\(uid)"
            let url = BLEndpoint.URL.payment
            return BLEndpointModel(url: url, token: nil, method: "DELETE", query: query, body: nil)
        case .Sell(.Delete(uid: let uid)):
            let query = "?id=\(uid)"
            let url = BLEndpoint.URL.sell
            return BLEndpointModel(url: url, token: nil, method: "DELETE", query: query, body: nil)
        case .Sell(.Disable(uid: let uid, body: let body)):
            let query = "?id=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            return BLEndpointModel(url: url, token: nil, method: "PUT", query: query, body: body)
        case .Payment(.Load(customerId: let id, token: let token)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            let query = "?customer=\(id)"
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Payment(.Save(body: let body, token: let token)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            return BLEndpointModel(url: url, token: token, method: "POST", query: nil, body: body)
        case .Customer(.LoadPage(query: let query, token: let token)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Customer(.Search(query: let query, token: let token)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer-search"
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        }
    }
}

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
    
    public static func prepareEndpoint(to: BLEndpointType) -> BLEndpointModel {
        
        switch to {
        case .RefreshToken:
            let result = BLEndpointModel(url: BLEndpoint.URL.Server.RefreshToken,
                                      token: nil,
                                      method: "POST",
                                      query: nil)
            return result
        case .GetAllPeriod:
            let result = BLEndpointModel(url: BLEndpoint.URL.period,
                                        token: nil,
                                        method: "GET",
                                        query: nil)
            return result
        case .GetAllDiscount:
            let result = BLEndpointModel(url: BLEndpoint.URL.discount,
                                        token: nil,
                                        method: "GET",
                                        query: nil)
            return result
        case .SaveNewSell(let token, let body):
            let result = BLEndpointModel(url: BLEndpoint.URL.sell,
                                        token: token,
                                        method: "POST",
                                        query: nil,
                                        body: body)
            return result
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

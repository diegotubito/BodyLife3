//
//  Constants.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 07/11/2020.
//

import Foundation

public enum BLServer: String {
    case Develop = "http://127.0.0.1:2999"
    case Production = "https://bodyshaping-heroku.herokuapp.com"
}

public class BLEndpointModel {
    var url : String
    var token : String?
    var method : String
    var query : String?
    var body : [String : Any]?
    
    public init(url: String, token: String?, method: String, query: String?, body: [String : Any]?) {
        self.url = url
        self.token = token
        self.method = method
        self.query = query
        self.body = body
    }
}

public enum BLNetworkError: String, Error {
    case missingUrl = "Missing URL String"
    case missingMethod = "Missing method GET - POST - UPDATE - DELETE"
    case wrongUrl = "URL error"
    case invalidToken = "Validation Token Expired or Invalid"
    case unknown_error = "Some error ocurred"
    
    case server_error = "Error Code 500"
    case tokenNotProvided = "Token Not Provided"
    case notFound = "Endpoint not found"
    case badRequest = "Bad Request"
    case serializationError = "Serialization Error"
}

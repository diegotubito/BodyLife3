//
//  Constants.swift
//  BLServerManager
//
//  Created by David Diego Gomez on 07/11/2020.
//

import Foundation

public struct BLEndpointModel {
    var url : String
    var token : String?
    var method : String
    var query : String?
    var body : [String : Any]?
}

public enum BLEndpointType {
    case RefreshToken(body: [String : Any])
    case GetAllPeriod
    case GetAllDiscount
    case SaveNewSell(token: String, body: [String : Any])
    case CheckServerConnection
    case Transaction(uid: String, path: String, key: String, value: Double)
    case Stock(uid: String, path: String)
    case ConnectToMongoDB(query: String)
    case DisconnectMongoDB
    case DeleteSell(uid: String)
    case DeletePayment(uid: String)
    case CancelRegister(uid: String, body: [String: Any])
    case LoadPayments(customerId: String, token: String)
    
}

public enum BLServer: String {
    case Develop = "http://127.0.0.1:2999"
    case Production = "https://bodyshaping-heroku.herokuapp.com"
}

public struct BLEndpoint {
    public struct URL {
        public struct Firebase {
            public static let Login = BLServerManager.baseUrl.rawValue + "/v1/firebase/auth/login"
            public static let currentUser = BLServerManager.baseUrl.rawValue + "v1/firebase/auth/currentUser"
            public static let transaction = BLServerManager.baseUrl.rawValue + "/v1/firebase/database/transaction"
            public static let database = BLServerManager.baseUrl.rawValue + "/v1/firebase/database"
        }
        
        public struct Server {
            public static let CheckServerConnection = BLServerManager.baseUrl.rawValue + "/v1/checkServerConnection"
            public static let RefreshToken =  BLServerManager.baseUrl.rawValue + "/v1/firebase/auth/refreshToken"
            public static let ConnectMongodb = BLServerManager.baseUrl.rawValue + "/v1/connect-mongodb"
            public static let DisconnectMongodb = BLServerManager.baseUrl.rawValue + "/v1/close-mongodb"
        }
        
        public static let period = "\(BLServerManager.baseUrl.rawValue)/v1/period"
        public static let discount = "\(BLServerManager.baseUrl.rawValue)/v1/discount"
        public static let sell = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
        public static let payment = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
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

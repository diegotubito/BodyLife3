//
//  Configuration.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa
import BLServerManager

public enum EndpointType {
    case RefreshToken(body: [String : Any])
    case GetAllPeriod
    case GetAllDiscount
    case CheckServerConnection
    case Transaction(uid: String, path: String, key: String, value: Double)
    case Stock(uid: String, path: String)
    case ConnectToMongoDB(query: String)
    case DisconnectMongoDB
    
    case Payment(PaymentType)
    case Sell(SellType)
    case Customer(CustomerType)
    case Article(ArticleType)
    case Image(ImageType)
    case Firebase(FirebaseType)
    case Period(PeriodType)
    case Discount(DiscountType)
    case Activity(ActivityType)
    
    public enum ActivityType {
        case Save(body: [String: Any])
    }
    
    public enum DiscountType {
        case Save(body: [String: Any])
    }
    
    public enum PeriodType {
        case Save(body: [String: Any])
    }
    
    public enum CustomerType {
        case LoadPage(query: String)
        case Search(query: String)
        case Save(body: [String : Any])
        case Delete(uid: String)
        case Update(uid: String, body: [String: Any])
        case FindByDNI(dni: String)
    }
    
    public enum SellType {
        case Save(body: [String : Any])
        case Disable(uid: String, body: [String: Any])
        case Delete(uid: String)
    }
    
    public enum PaymentType {
        case Save(body: [String : Any]?)
        case Load(customerId: String)
        case Delete(uid: String)
    }
    
    public enum ArticleType {
        case Load(userUID: String, path: String)
    }
    
    public enum ImageType {
        case LoadThumbnail(uid: String)
        case SaveThumbnail(body: [String: Any])
        case LoadBigSize(userUID: String, customerUID: String)
        case LoadBigSizeFromOldBucket(customerUID: String)
    }
    
    public enum FirebaseType {
        case Login(body: [String: Any])
        case SighUp(body: [String: Any])
        case SendVerificationMail(body: [String: Any])
        case Save(path: String, body: [String: Any])
    }
}

class Endpoint {
    static func Create(to: EndpointType) -> BLEndpointModel {
        
        switch to {
        case .RefreshToken(body: let body):
            return BLEndpointModel(url: myURL.Server.RefreshToken, token: nil, method: "POST", query: nil, body: body)
        case .GetAllPeriod:
            return BLEndpointModel(url: myURL.period, token: nil, method: "GET", query: nil, body: nil)
        case .GetAllDiscount:
            return BLEndpointModel(url: myURL.discount, token: nil, method: "GET", query: nil, body: nil)
        case .Sell(.Save(body: let body)):
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: myURL.sell, token: token, method: "POST", query: nil, body: body)
        case .CheckServerConnection:
            return BLEndpointModel(url: myURL.Server.CheckServerConnection, token: nil, method: "GET", query: nil, body: nil)
        case .Transaction(uid: let uid, path: let path, key: let key, value: let value):
            let body = ["transaction": value]
            let url = myURL.Firebase.transaction + "/users:\(uid):\(path):\(key)"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Stock(uid: let uid, path: let path):
            let url = myURL.Firebase.database + "/users:\(uid):\(path)"
            return BLEndpointModel(url: url, token: nil, method: "GET", query: nil, body: nil)
        case .ConnectToMongoDB(query: let query):
            let url = "\(myURL.Server.ConnectMongodb)"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: query, body: nil)
        case .DisconnectMongoDB:
            let url = myURL.Server.DisconnectMongodb
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: nil)
        case .Payment(.Delete(uid: let uid)) :
            let query = "?id=\(uid)"
            let url = myURL.payment
            return BLEndpointModel(url: url, token: nil, method: "DELETE", query: query, body: nil)
        case .Sell(.Delete(uid: let uid)):
            let query = "?id=\(uid)"
            let url = myURL.sell
            return BLEndpointModel(url: url, token: nil, method: "DELETE", query: query, body: nil)
        case .Sell(.Disable(uid: let uid, body: let body)):
            let query = "?id=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            return BLEndpointModel(url: url, token: nil, method: "PUT", query: query, body: body)
        case .Payment(.Load(customerId: let id)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            let query = "?customer=\(id)"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Payment(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "POST", query: nil, body: body)
        case .Customer(.LoadPage(query: let query)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Customer(.Search(query: let query)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer-search"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Customer(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "POST", query: nil, body: body)
        case .Customer(.Delete(uid: let uid)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let query = "?id=\(uid)"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "DELETE", query: query, body: nil)
        case .Customer(.Update(uid: let uid, body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let query = "?id=\(uid)"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "PUT", query: query, body: body)
        case .Customer(.FindByDNI(dni: let dni)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customerByDni"
            let query = "?dni=\(dni)"
            let token = UserSaved.GetToken()
            return BLEndpointModel(url: url, token: token, method: "GET", query: query, body: nil)
        case .Article(.Load(userUID: let id, path: let path)):
            let url = myURL.Firebase.database + "/users:\(id):\(path)"
            return BLEndpointModel(url: url, token: nil, method: "GET", query: nil, body: nil)
        case .Image(.LoadThumbnail(uid: let uid)) :
            let query = "?uid=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            return BLEndpointModel(url: url, token: nil, method: "GET", query: query, body: nil)
        case .Image(.LoadBigSize(userUID: let userUID, customerUID: let customerUID)) :
            let query = "?filename=\(userUID)/customer/\(customerUID).jpeg"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImage"
            return BLEndpointModel(url: url, token: nil, method: "GET", query: query, body: nil)
        case .Image(.LoadBigSizeFromOldBucket(customerUID: let customerUID)) :
            let query = "?filename=socios/\(customerUID).jpeg"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImageFromOldBucket"
            return BLEndpointModel(url: url, token: nil, method: "GET", query: query, body: nil)
        case .Image(.SaveThumbnail(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Firebase(.Login(body: let body)):
            let url = myURL.Firebase.Login
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Firebase(.SighUp(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/firebase/admin/user"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Firebase(.SendVerificationMail(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sendMail"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Firebase(.Save(path: let path, body: let body)):
            let url = myURL.Firebase.database + path
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Period(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/period"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Discount(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/discount"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
        case .Activity(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/activity"
            return BLEndpointModel(url: url, token: nil, method: "POST", query: nil, body: body)
            
        }
    }
}

public struct myURL {
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

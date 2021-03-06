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
    case CheckServerConnection
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
    case SecondaryUser(SecondaryUserType)
    case Expense(ExpenseType)
    case ExpenseCategory(ExpenseCategoryType)
    
    public enum ExpenseCategoryType {
        case Load
    }
    
    public enum ExpenseType {
        case Load(fromDate: Double, toDate: Double)
        case Save(body: [String: Any])
        case Delete(_id: String)
        case Disable(_id: String)
    }
    
    public enum SecondaryUserType {
        case Load
        case Save(body: [String : Any])
        case Update(_id: String, body: [String: Any])
        case Disable(_id: String)
        case Enable(_id: String)
        case Delete(_id: String)
        case Login(userName: String, password: String)
        case CreateFirstUser
    }
    
    public enum ActivityType {
        case Save(body: [String: Any])
    }
    
    public enum DiscountType {
        case Save(body: [String: Any])
        case LoadAll
    }
    
    public enum PeriodType {
        case Save(body: [String: Any])
        case LoadAll
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
        case LoadThumbnail(_id: String)
        case SaveThumbnail(body: [String: Any])
        case UpdateThumbnail(body: [String: Any])
        case LoadBigSize(userUID: String, customerUID: String)
        case LoadBigSizeFromOldBucket(customerUID: String)
    }
    
    public enum FirebaseType {
        case Login(body: [String: Any])
        case SighUp(body: [String: Any])
        case SendVerificationMail(body: [String: Any])
        case Save(path: String, body: [String: Any])
        case Update(path: String, body: [String: Any])
        case Load(path: String)
        case Transaction(path: String, key: String, amount: Double)
    }
}

class Endpoint {
    static func Create(to: EndpointType) -> BLEndpointModel {
        let token = MainUserSession.GetToken()
        let secondaryToken = SecondaryUserSession.GetUser()?.token
    
        switch to {
        case .RefreshToken(body: let body):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/auth/refreshToken"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Period(.LoadAll):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/period"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .Discount(.LoadAll):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/discount"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .Sell(.Save(body: let body)):()
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .CheckServerConnection:
            let url = BLServerManager.baseUrl.rawValue + "/v1/checkServerConnection"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .ConnectToMongoDB(query: let query):
            let url = BLServerManager.baseUrl.rawValue + "/v1/connect-mongodb"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: query, body: nil)
        case .DisconnectMongoDB:
            let url = BLServerManager.baseUrl.rawValue + "/v1/close-mongodb"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: nil)
        case .Payment(.Delete(uid: let uid)) :
            let query = "?id=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "DELETE", query: query, body: nil)
        case .Sell(.Delete(uid: let uid)):
            let query = "?id=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "DELETE", query: query, body: nil)
        case .Sell(.Disable(uid: let uid, body: let body)):
            let query = "?id=\(uid)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: body)
        case .Payment(.Load(customerId: let id)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            let query = "?customer=\(id)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Payment(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Customer(.LoadPage(query: let query)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Customer(.Search(query: let query)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer-search"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Customer(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Customer(.Delete(uid: let uid)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let query = "?id=\(uid)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "DELETE", query: query, body: nil)
        case .Customer(.Update(uid: let uid, body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customer"
            let query = "?id=\(uid)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: body)
        case .Customer(.FindByDNI(dni: let dni)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/customerByDni"
            let query = "?dni=\(dni)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Article(.Load(userUID: let id, path: let path)):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/database" + "/users:\(id):\(path)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .Image(.LoadThumbnail(_id: let _id)) :
            let query = "?_id=\(_id)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Image(.LoadBigSize(userUID: let userUID, customerUID: let customerUID)) :
            let query = "?filename=\(userUID)/customer/\(customerUID).jpeg"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImage"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Image(.LoadBigSizeFromOldBucket(customerUID: let customerUID)) :
            let query = "?filename=socios/\(customerUID).jpeg"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImageFromOldBucket"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Image(.SaveThumbnail(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Image(.UpdateThumbnail(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: nil, body: body)
        case .Firebase(.Login(body: let body)):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/auth/login"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Firebase(.SighUp(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/firebase/admin/user"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Firebase(.SendVerificationMail(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sendMail"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Firebase(.Save(path: let path, body: let body)):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/database" + path
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Firebase(.Update(path: let path, body: let body)):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/database" + path
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: nil, body: body)
        case .Firebase(.Load(path: let path)):
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/database" + path
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .Firebase(.Transaction(path: let path, key: let key, amount: let amount)):
            let body = ["transaction": amount]
            let url = BLServerManager.baseUrl.rawValue + "/v1/firebase/database/transaction" + "\(path):\(key)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Period(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/period"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Discount(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/discount"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Activity(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/activity"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
            
        case .SecondaryUser(.Load):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        case .SecondaryUser(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .SecondaryUser(.Delete(_id: let _id)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user"
            let query = "?_id=\(_id)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "DELETE", query: query, body: nil)
        case .SecondaryUser(.Disable(_id: let _id)):
            let query = "?_id=\(_id)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user/disable"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: nil)
        case .SecondaryUser(.Enable(_id: let _id)):
            let query = "?_id=\(_id)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user/enable"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: nil)
        case .SecondaryUser(.Update(_id: let _id, body: let body)):
            let query = "?_id?\(_id)"
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/sercondary_user"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: body)
        case .SecondaryUser(.Login(userName: let userName, password: let password)):
            let body = ["userName" : userName,
                        "password" : password]
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user/login"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .SecondaryUser(.CreateFirstUser):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/secondary_user/first_user"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: nil)
        case .Expense(.Load(fromDate: let from, toDate: let to)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/expense_range"
            let query = "?from=\(from)&to=\(to)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: query, body: nil)
        case .Expense(.Save(body: let body)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/expense"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "POST", query: nil, body: body)
        case .Expense(.Delete(_id: let id)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/expense"
            let query = "?id=\(id)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "DELETE", query: query, body: nil)
        case .Expense(.Disable(_id: let id)):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/expense/disable"
            let query = "?id=\(id)"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "PUT", query: query, body: nil)
        case .ExpenseCategory(.Load):
            let url = "\(BLServerManager.baseUrl.rawValue)/v1/expense_category"
            return BLEndpointModel(url: url, token: token, tokenSecondaryUser: secondaryToken, method: "GET", query: nil, body: nil)
        }
    }
}

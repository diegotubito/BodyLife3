//
//  CustomerModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

struct RegisterType {
    static let income = "INCOME"
    static let expense = "EXPENSE"
}

struct BriefCustomer: Decodable {
    var childID : String
    var createdAt : Double
    var dni : String
    var surname : String
    var name : String
    var thumbnailImage : String?
}

struct CustomerStatus: Decodable {
    var childID : String
    var surname : String
    var name : String
    var balance : Double
    var expiration : Double
    var childIDLastType : String
    var childIDLastActivity : String
    var childIDLastDiscount : String
}

struct SellRegisterModel: Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDDiscount : String?
    var childIDActivity : String?
    var childIDArticle : String?
    var childIDPeriod : String?
    var createdAt : Double
    var amountDiscounted : Double
    var fromDate : Double?
    var toDate : Double?
    var amount : Double
    var amountToPay : Double
    var displayName : String
    var isEnabled : Bool
    var payments : [Payment]?
    var registerType : String
    var queryByDMY : String
    var queryByMY : String
    var queryByY : String
    
    var balance : Double?
    var totalPayment : Double?
}

struct Payment: Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDSell : String
    var amount : Double
}

//
//  CustomerModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

struct CustomerModel: Decodable {
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
    var transaction : Double
    var expiration : Double
    var childIDLastActivity : String
    var childIDLastPeriod : String
    var childIDLastDiscount : String
}

struct SellRegisterModel: Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDDiscount : String
    var childIDActivity : String
    var childIDPeriod : String
    var createdAt : Double
    var discount : Double
    var fromDate : Double
    var toDate : Double
    var price : Double
    var displayName : String
    var payments : [PaymentModel]?
    
    var balance : Double?
    var totalPayment : Double?
}

struct PaymentModel: Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDSell : String
    var total : Double
}

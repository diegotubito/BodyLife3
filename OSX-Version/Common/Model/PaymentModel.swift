//
//  PaymentModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 30/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa


struct Payment: Encodable, Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDSell : String
    var amount : Double
}


class PaymentModel {
    struct Populated: Decodable {
        var _id : String
        var customer : CustomerModel.Customer?
        var sell : SellModel.Register?
        var isEnabled : Bool
        var timestamp : Double
        var paidAmount : Double
        var productCategory : String
    }
    
    struct Register : Encodable, Decodable {
        var _id : String?
        var customer : String
        var sell : String
        var isEnabled : Bool
        var timestamp : Double
        var paidAmount : Double
        var productCategory : String
    }
}

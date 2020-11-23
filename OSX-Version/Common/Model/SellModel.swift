//
//  SellModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class SellModel {
  
    struct Register: Encodable, Decodable {
        var _id: String?
        var customer : String?
        var discount : String?
        var activity : String?
        var article : String?
        var period : String?
        var timestamp : Double
        var fromDate : Double?
        var toDate : Double?
        var quantity : Int?
        var isEnabled : Bool
        var productCategory : String
        var price: Double?
        var priceList: Double?
        var priceCost : Double?
        var description: String
        
        var totalPayment : Double?
        var balance : Double?
    }

}

//
//  CustomerModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

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

class CustomerModel {
    
    struct Customer : Encodable, Decodable {
        var _id: String?
        var uid : String
        var timestamp : Double
        var dni : String
        var lastName : String
        var firstName : String
        var fullname : String
        var thumbnailImage : String?
        var email : String
        var phoneNumber : String
        var user: String
        var location : Location?
        var dob: Double
        var genero: String
        var obraSocial : String?
        var isEnabled : Bool
    }
    
    struct Location : Decodable, Encodable {
        var _id : String?
        var longitude: Double?
        var latitude : Double?
        var coordinates : [Double]?
        var street : String?
        var locality : String?
        var state : String?
        var country : String?
    }
}


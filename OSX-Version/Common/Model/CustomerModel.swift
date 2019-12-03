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

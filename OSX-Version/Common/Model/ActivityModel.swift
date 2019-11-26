//
//  ActivityModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct MembershipModel {
    var activities : [ActivityModel]
    var periods : [PeriodModel]
}

struct ActivityModel : Decodable {
    var childID : String
    var name : String
    var isEnabled : Bool
    var createdAt : Double
}

struct PeriodModel: Decodable {
    var childID : String
    var childIDActivity : String
    var name : String
    var isEnabled : Bool
    var createdAt : Double
    var price : Double
}

struct DiscountModel: Decodable {
    var childID  : String
    var name : String
    var isEnabled : Bool
    var expiration : Double
    var multiplier : Double
    var createdAt : Double
}

//
//  ActivityModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct MembershipModel {
    var activities : [ServiceTypeModel]
    var periods : [ActivityModel]
}

struct ServiceTypeModel : Decodable {
    var childID : String
    var name : String
    var isEnabled : Bool
    var createdAt : Double
}

struct ActivityModel: Decodable {
    var childID : String
    var childIDType : String
    var name : String
    var isEnabled : Bool
    var createdAt : Double
    var price : Double
    var days : Int
}

struct ArticleModel: Decodable {
    var childID : String
    var name : String
    var isEnabled : Bool
    var createdAt : Double
    var price : Double
    var stock : Int
    var minStock : Int
    var maxStock : Int
    var sellCount: Int
}

struct DiscountModel: Decodable {
    var childID  : String
    var name : String
    var isEnabled : Bool
    var expiration : Double
    var multiplier : Double
    var createdAt : Double
    var isRemovable : Bool
}

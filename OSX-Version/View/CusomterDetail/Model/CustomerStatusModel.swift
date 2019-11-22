//
//  CustomerStatusModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct CustomerStatusModel {
    var isWaiting : Bool = false
    
    struct CustomerStatus: Decodable {
        var childID : String
        var surname : String
        var name : String
        var balance : Double
        //  var expirationDate : Double
        var activities : String
    }
    
}

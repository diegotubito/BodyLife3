//
//  DiscountModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class DiscountModel {
    struct Register: Encodable, Decodable {
        var _id  : String
        var description : String
        var isEnabled : Bool
        var expiration : Double
        var factor : Double
        var timestamp : Double
    }
}

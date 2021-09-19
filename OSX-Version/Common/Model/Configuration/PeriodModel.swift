//
//  PeriodModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class PeriodModel {
    
    struct Register: Decodable, Encodable {
        var _id : String
        var description : String
        var isEnabled : Bool
        var timestamp : Double
        var activity : String
        var price : Double
        var days : Int
    }
    
    struct Populated : Codable {
        var _id : String
        var description : String
        var isEnabled : Bool
        var timestamp : Double
        var activity : ActivityModel.NewRegister?
        var price : Double
        var days : Int
    }
   
}

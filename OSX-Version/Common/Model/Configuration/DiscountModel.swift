//
//  DiscountModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class DiscountModel {
    struct Old : Decodable {
        var childID : String
        var descripcion : String
        var esOculto : Bool
        var fechaCreacion : String
        var fechaVencimiento : String
        var multiplicador : Double
    }
    
    struct NewRegister: Encodable, Decodable {
        var _id  : String
        var description : String
        var isEnabled : Bool
        var expiration : Double
        var factor : Double
        var timestamp : Double
    }
    
    struct Register: Encodable, Decodable {
        var childID  : String
        var name : String
        var isEnabled : Bool
        var expiration : Double
        var multiplier : Double
        var createdAt : Double
        var isRemovable : Bool
    }

}

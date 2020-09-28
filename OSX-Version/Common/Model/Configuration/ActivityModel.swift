//
//  ActivityModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation


class ActivityModel {
    
    struct Old: Decodable {
        var childID : String
        var descripcion : String
        var fechaCreacion : String
        var oculto : Bool
    }
    
    struct NewRegister: Decodable, Encodable {
        var _id : String
        var description : String
        var isEnabled : Bool
        var timestamp : Double
    }
    
    
    struct Register: Decodable {
        var childID : String
        var childIDType : String
        var name : String
        var isEnabled : Bool
        var createdAt : Double
        var price : Double
        var days : Int
    }
   
}


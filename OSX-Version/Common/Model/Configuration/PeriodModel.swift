//
//  PeriodModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class PeriodModel {
    
    struct Old: Decodable {
        var childID : String
        var cantidadDeClases : Int
        var fechaCreacion : String
        var oculto : Bool
        var childIDActividad : String
        var descripcion : String
        var dias : Int
        var esPorClase : Bool
        var esPorVencimiento : Bool
        var precio : Double
    }
    
    struct NewRegister: Decodable, Encodable {
        var _id : String
        var description : String
        var isEnabled : Bool
        var timestamp : Double
        var activity : String
        var price : Double
        var days : Int
    }
   
}


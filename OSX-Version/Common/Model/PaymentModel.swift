//
//  PaymentModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 30/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

class PaymentModel {
    struct OldCarnet : Decodable {
        var childID : String
        var childIDSocio : String
        var childIDVentaCarnet : String
        var esAnulado : Bool
        var fechaCreacion : String
        var importeCobrado : Double
    }
    
    struct OldArticulo : Decodable {
        var childID : String
        var childIDSocio : String
        var childIDVentaArticulo : String
        var esAnulado : Bool
        var fechaCreacion : String
        var importeCobrado : Double
    }
    
    struct Request {
        var _id : String
        var customer : String
        var sell : String
        var isEnabled : Bool
        var timestamp : String
        var paidAmount : Double
    }
    
    struct Response : Encodable, Decodable {
        var _id : String
        var customer : String
        var sell : String
        var isEnabled : Bool
        var timestamp : Double
        var paidAmount : Double
        var operationCategory : String
    }
    
    struct ViewModel : Decodable {
        var _id : String
        var customer : String
        var sell : String
        var isEnabled : Bool
        var timestamp : String
        var paidAmount : Double
    }
}

//
//  ArticleModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class ArticleModel {
    struct Old: Decodable {
        var childID : String
        var descripcion : String
        var fechaCreacion : String
        var esOculto : Bool
        var precioCompra : Double
        var precioVenta : Double
    }
    
    struct NewRegister: Decodable, Encodable {
        var _id : String?
        var description : String
        var isEnabled : Bool
        var timestamp : Double
        var price : Double
        var priceCost : Double
        var stock : Int
        var minStock : Int
        var maxStock : Int
    }
    
    struct Response: Decodable, Encodable {
        var _id : String?
        var article : String
        var customer : String
        var description : String
        var isEnabled : Bool
        var price : Double
        var priceList : Double
        var productCategory : String
        var quantity : Int
        var timestamp : Double
    }
    
    struct Register: Decodable {
        var childID : String
        var name : String
        var isEnabled : Bool
        var createdAt : Double
        var price : Double
        var priceList: Double
        var stock : Int
        var minStock : Int
        var maxStock : Int
        var sellCount: Int
    }
    
    struct ViewModel: Decodable {
        var response : String
        var articles : [NewRegister]
        var count: Int
    }
}

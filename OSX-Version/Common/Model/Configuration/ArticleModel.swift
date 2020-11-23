//
//  ArticleModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

class ArticleModel {
   
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
    
}

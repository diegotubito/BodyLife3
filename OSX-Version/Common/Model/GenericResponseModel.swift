//
//  GenericResponseModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 14/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ResponseModel <T: Decodable> : Decodable{
    var success : Bool?
    var data : T?
    var count : Int?
    var errorMessage : String?
}


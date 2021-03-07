//
//  MainOptionModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

struct MainOptionModel {
    var data : DataModel!
    
    struct DataModel : Codable {
        var type : String
        var columns : [Column] = []
        var items : [Item] = []
    }
    
    struct Item : Codable {
        var title : String?
        var isEnabled : Bool
        var aux : String?
        var doubleValue : Double?
    }
    
    struct Column : Codable {
        var name : String?
        var isEditable : Bool
        var width: Double?
        var maxWidth: Double?
        var minWidth: Double?
        var fieldName: String?
    }
}

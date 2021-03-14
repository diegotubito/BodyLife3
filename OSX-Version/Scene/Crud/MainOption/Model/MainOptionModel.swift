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
        var column: GenericTableViewColumnModel
        var items : [Item] = []
    }
    
    struct Item : Codable {
        var title : String?
        var isEnabled : Bool
        var aux : String?
        var doubleValue : Double?
    }
}

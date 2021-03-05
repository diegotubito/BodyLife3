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
    
    struct DataModel : Decodable {
        var type : String
        var columns : [Column] = []
        var items : [Item] = []
    }
    
    struct Item : Decodable {
        var title : String?
    }
    
    struct Column : Decodable {
        var name : String?
    }
}

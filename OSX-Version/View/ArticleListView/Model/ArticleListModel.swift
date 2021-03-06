//
//  SellProductModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

struct ArticleListModel {
    var articles : [ArticleModel.NewRegister]!
}

struct StockModel: Decodable {
    var stock : Double
}

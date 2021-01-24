//
//  ProductListView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

class ProductListView: GenericCollectionView<StockCrudCell, ArticleModel.NewRegister> {
    override func commonInit() {
        super .commonInit()
        numberOfVisibleItems = 5
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
    }
}

//
//  SellProductViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol ArticleListViewModelContract {
    init(withView view: ArticletListViewContract)
    var model : ArticleListModel! {get}
    func loadProducts()
    func getProducts() -> [ArticleModel.NewRegister]
}

protocol ArticletListViewContract {
    func showLoading()
    func hideLoading()
    func displayList()
    func showError()
}

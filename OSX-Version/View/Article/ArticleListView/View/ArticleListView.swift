//
//  SellProductView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct ExampleItemModel {
    var title : String
}

class ArticleListView : GenericCollectionView<ArticleViewItem, ArticleModel> {
    var viewModel : ArticleListViewModelContract!
      
    override func commonInit() {
        super .commonInit()
        viewModel = ArticleListViewModel(withView: self)
        viewModel.loadProducts()
        numberOfVisibleItems = 4
    }
}

extension ArticleListView : ArticletListViewContract {
    func showError() {
        showErrorConnectionView()
    }
    func showLoading() {
      
    }
    
    func hideLoading() {
    }
    
    func displayList() {
        items = viewModel.getProducts()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


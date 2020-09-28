//
//  SellProductView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let needUpdateArticleList = Notification.Name("needUpdateArticleList")
}


class ArticleListView : GenericCollectionView<ArticleViewItem, ArticleModel.Register> {
    var viewModel : ArticleListViewModelContract!
      
    override func commonInit() {
        super .commonInit()
        
        viewModel = ArticleListViewModel(withView: self)
        viewModel.loadProducts()
        numberOfVisibleItems = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(articleDidChangeHandler), name: .needUpdateArticleList, object: nil)
    }
    
    @objc func articleDidChangeHandler() {
        viewModel.loadProducts()
    }

}


extension ArticleListView : ArticletListViewContract {
    func showError() {
       
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


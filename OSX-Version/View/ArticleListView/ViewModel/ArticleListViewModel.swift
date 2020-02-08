//
//  SellProductViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class ArticleListViewModel : ArticleListViewModelContract {
    var model: ArticleListModel!
    var _view : ArticletListViewContract!
   
    required init(withView view: ArticletListViewContract) {
        self.model = ArticleListModel()
        self._view = view
    }
    
    func loadProducts() {
        self._view.showLoading()
        let path = Paths.productArticle
        ServerManager.ReadJSON(path: path) { (json, error) in
            self._view.hideLoading()
            guard error == nil else {
                self._view.showError()
                return
            }
            
            guard let json = json else {
                self._view.showError()
                return
            }
            
            let jsonArray = ServerManager.jsonArray(json: json)
            do {
                //this block sometime cause a crush
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let articles = try JSONDecoder().decode([ArticleModel].self, from: data)
               
                self.model.products = articles
                self.filterAndSort()
                    
                self._view.displayList()
            } catch {
                self._view.showError()
            }
            
        }
    }
    
    func filterAndSort() {
        let filtered = model.products.filter { (product) -> Bool in
            return product.isEnabled != false
        }
        let sorted = filtered.sorted(by: { $0.sellCount > $1.sellCount })
        model.products = sorted
    }
    
    func getProducts() -> [ArticleModel] {
        
        return model.products
    }
}

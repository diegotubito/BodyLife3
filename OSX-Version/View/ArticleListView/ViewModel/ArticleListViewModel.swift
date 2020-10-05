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
        _view.showLoading()
       
        let url = "http://127.0.0.1:2999/v1/article"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            
            guard let data = data else {
               
                return
            }
            do {
                let response = try JSONDecoder().decode(ArticleModel.ViewModel.self, from: data)
                self.model.response = response
                for i in response.articles {
                    print(i.priceCost)
                }
                self.filterAndSort()
            } catch {
                return
            }
        }
    }
    
    func filterAndSort() {
        let sorted = model.response.articles.sorted(by: { $0.description > $1.description })
        model.response.articles = sorted
        _view.displayList()
    }
    
    func getProducts() -> [ArticleModel.NewRegister] {
        
        return model.response.articles
    }
}

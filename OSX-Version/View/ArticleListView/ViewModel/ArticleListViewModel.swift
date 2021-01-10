//
//  SellProductViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class ArticleListViewModel : ArticleListViewModelContract {
    var model: ArticleListModel!
    var _view : ArticletListViewContract!
    
    struct Stock {
        var stock : Int
    }
   
    required init(withView view: ArticletListViewContract) {
        self.model = ArticleListModel()
        self._view = view
    }
    
    func loadProducts() {
        _view.showLoading()
        let uid = MainUserSession.GetUID()
        let path = "product:article"
        let endpoint = Endpoint.Create(to: .Article(.Load(userUID: uid, path: path)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ArticleModel.NewRegister]>) in
            self.model.articles = response.data
            self.filterAndSort()
        } fail: { (error) in
            print("Could not load Articles", error.rawValue)
        }
    }
    
    func filterAndSort() {
        if model.articles == nil {return}
        let sorted = model.articles.sorted(by: { $0.description > $1.description })
        let filtered = sorted.filter({$0.isEnabled})
        model.articles = filtered
        _view.displayList()
    }
    
    func getProducts() -> [ArticleModel.NewRegister] {
        return model.articles
    }
}

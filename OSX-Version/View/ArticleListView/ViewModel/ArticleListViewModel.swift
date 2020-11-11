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
        let uid = UserSaved.GetUID()
        let path = Paths.productArticle
        let url = BLEndpoint.URL.Firebase.database + "/users:\(uid):\(path)"
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                return
            }
            do {
                let articles = try JSONDecoder().decode([ArticleModel.NewRegister].self, from: data)
                self.model.articles = articles
                self.filterAndSort()
            } catch {
                return
            }
        }
    }
    
    func filterAndSort() {
        let sorted = model.articles.sorted(by: { $0.description > $1.description })
        let filtered = sorted.filter({$0.isEnabled})
        model.articles = filtered
        _view.displayList()
    }
    
    func getProducts() -> [ArticleModel.NewRegister] {
        return model.articles
    }
}

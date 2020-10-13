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
    
    struct Stock {
        var stock : Int
    }
   
    required init(withView view: ArticletListViewContract) {
        self.model = ArticleListModel()
        self._view = view
    }
    
    func loadProducts() {
        _view.showLoading()
        let url = "\(Config.baseUrl.rawValue)/v1/article"
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                return
            }
            do {
                let response = try JSONDecoder().decode(ArticleModel.ViewModel.self, from: data)
                self.model.response = response
                self.loadStock()
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
    
    func loadStock() {
        _view.showLoading()
        ServerManager.LoadStock { (data, error) in
            guard error == nil, let data = data else {
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                for (key, value) in json {
                    let articles = self.model.response.articles.filter({$0.isEnabled && $0._id == key})
                    if articles.count > 0 {
                        if let index = self.model.response.articles.firstIndex(where: {$0._id == key}) {
                            let stockJSON = value as? [String : Any]
                            let stock = stockJSON?["stock"] as! Int
                            self.model.response.articles[index].stock = stock
                        }
                    }
                }
            }
            
            self.filterAndSort()
            
        }
    }
}

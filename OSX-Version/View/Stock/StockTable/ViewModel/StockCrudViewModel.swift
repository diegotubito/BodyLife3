//
//  StockCrudViewModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

protocol StockTableViewModelProtocol {
    init(withView view: StockTableViewProtocol)
    var model : StockTableModel! {get}
    func loadProducts()
    func saveNewStockValue(value: Int, row: Int)
}

protocol StockTableViewProtocol {
    func showLoadingProducts()
    func hideLoadingProducts()
    func showProductList()
    func showSavingStock()
    func hideSavingStock()
}

class StockTableViewModel: StockTableViewModelProtocol {
    
    var model: StockTableModel!
    var _view: StockTableViewProtocol!
    
    required init(withView view: StockTableViewProtocol) {
        model = StockTableModel()
        _view = view
    }
    
     
    func loadProducts() {
        _view.showLoadingProducts()
        let uid = MainUserSession.GetUID()
        let path = "product:article"
        let endpoint = Endpoint.Create(to: .Article(.Load(userUID: uid, path: path)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ArticleModel.NewRegister]>) in
            self._view.hideLoadingProducts()
            self.model.articles = response.data
            self.filterAndSort()
        } fail: { (error) in
            self._view.hideLoadingProducts()
            print("Could not load Articles", error)
        }
    }
    
    func filterAndSort() {
        if model.articles == nil {return}
        let sorted = model.articles.sorted(by: { $0.description > $1.description })
        let filtered = sorted.filter({$0.isEnabled})
        model.articles = filtered
        _view.showProductList()
    }
    
    func saveNewStockValue(value: Int, row: Int) {
        _view.showSavingStock()
        let article = model.articles[row]
        let id = article._id ?? ""
        let uid = MainUserSession.GetUID()
        let path = "/users:\(uid):product:article:\(id)"
        let body = ["stock" : value]
        let endpoint = Endpoint.Create(to: .Firebase(.Update(path: path, body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            self._view.hideSavingStock()
            self.loadProducts()
            NotificationCenter.default.post(.init(name: .needUpdateArticleList))
        } fail: { (errorMessage) in
            print(errorMessage)
            self._view.showProductList()
        }

    }
}

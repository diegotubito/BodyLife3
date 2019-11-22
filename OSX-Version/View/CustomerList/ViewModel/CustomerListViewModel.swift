//
//  CustomerListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa

class CustomerListViewModel: CustomerListViewModelContract {
    
    var model: CustomerListModel!
    var _view : CustomerListViewContract!
    
    required init(withView view: CustomerListViewContract) {
        self._view = view
        self.model = CustomerListModel()
    }
    
    func loadCustomers() {
        _view.showLoading()
        DispatchQueue.global().async {
            let path = "briefData"
            ServerManager.ReadAll(path: path) { (array, error) in
                
                self._view.hideLoading()
                if error != nil {
                    self._view.showError()
                    return
                }
                do {
                    if array != nil {
                        let data = try JSONSerialization.data(withJSONObject: array!, options: [])
                        let registros = try JSONDecoder().decode([CustomerModel].self, from: data)
                        let fileredArray = registros.sorted(by: { $0.createdAt > $1.createdAt })
                        self.model.registros = fileredArray
                        self._view.showSuccess()
                    }
                } catch {
                    self._view.showError()
                }
            }
            
        }
    }
    
    
}


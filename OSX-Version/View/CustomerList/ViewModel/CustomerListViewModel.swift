//
//  CustomerListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa

class CustomerListViewModel: CustomerListViewModelContract {
    var loading = false
  
    var model: CustomerListModel!
    var _view : CustomerListViewContract!
    
    required init(withView view: CustomerListViewContract) {
        self._view = view
        self.model = CustomerListModel()
    }
    
    func loadCustomers(offset: Int) {
        if loading {return}
        loading = true
        _view.showLoading()
        let url = "http://127.0.0.1:2999/v1/customer?offset=\(offset)&limit=50"
        let _services = NetwordManager()
        _services.get(url: url, response: { (data, error) in
            self._view.hideLoading()
            self.loading = false
            guard error == nil, let data = data else {
                self._view.showError()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CustomerListModel.Response.self, from: data) 
                self.model.response = response
                self.model.customers.append(contentsOf: response.customers)
                self._view.showSuccess()
            } catch {
                self._view.showError()
            }

        })
    }
    
   
    
    func getTotalItems() -> Int {
        return model.response?.total_amount ?? 0
    }
}


//
//  CustomerStatusViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class CustomerStatusViewModel: CustomerStatusViewModelContract {
    var model: CustomerStatusModel!
    var _view : CustomerStatusViewContract!
    var receivedCustomer : CustomerModel!
    
    required init(withView view: CustomerStatusViewContract, receivedCustomer: CustomerModel) {
        self._view = view
        self.receivedCustomer = receivedCustomer
        self.model = CustomerStatusModel()
    }
    
    func loadData() {
        _view.showLoading()
        load()
    }
    
    func load() {
        let path = "statusData:\(receivedCustomer.childID)"
        
        ServerManager.Read(path: path) { (value:CustomerStatus?, error) in
            self._view.hideLoading()
            
            if error != nil, error != ServerError.body_serialization_error {
                self._view.showError(message: ErrorHandler.Server(error: error!))
                return
            }
            self.model.loadedStatus = value
            DispatchQueue.main.async {
                self._view.showSuccess(value: value)
            }
        }
    }
    
}

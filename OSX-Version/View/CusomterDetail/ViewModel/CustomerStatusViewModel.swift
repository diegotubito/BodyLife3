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
    }
    
    func loadData() {
        let path = "statusData:\(receivedCustomer.childID)"
        
         ServerManager.Read(path: path) { (value:CustomerStatusModel?, error) in
            DispatchQueue.main.async {
                self._view.showData(value: value)
            }
        }
    }
    
   
    
}

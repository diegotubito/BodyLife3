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
        let url = "http://127.0.0.1:2999/v1/customer?offset=0&limit=10"
        let _services = NetwordManager()
        _services.get(url: url, response: { (data, error) in
            guard error == nil, let data = data else {
                self._view.showError()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CustomerListModel.Response.self, from: data) 
                self.model.response = response
                self._view.showSuccess()
            } catch {
                print(error)
                self._view.showError()
            }

        })
    }
    
    func loadImage(row: Int, customer: BriefCustomer, completion: @escaping (String?) -> ()) {
        let path = "\(Paths.fullPersonalData):\(customer.childID):images"
        ServerManager.ReadJSON(path: path) { (data, error) in
            
            if error != nil {
                print("error al cargar string image")
                completion(nil)
                return
            }
          
            guard let data = data else {
                print("error al cargar string image")
                completion(nil)
                return
            }
            
            if let imageString = data["thumbnailImage"] as? String {
                 completion(imageString)
            }
            
        }
    }
    
    
    func getTotalItems() -> Int {
        return model.response?.total_amount ?? 0
    }
}


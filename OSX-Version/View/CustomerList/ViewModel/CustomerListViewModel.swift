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
    
    func loadCustomers(offset: Int) {
        print("loading...")
        _view.showLoading()
        let url = "http://127.0.0.1:2999/v1/customer?offset=\(offset)&limit=30"
        let _services = NetwordManager()
        _services.get(url: url, response: { (data, error) in
            self._view.hideLoading()
            guard error == nil, let data = data else {
                self._view.showError()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CustomerListModel.Response.self, from: data) 
                self.model.response = response
                for i in response.customers {
                    if self.model.customers.contains(where: {$0._id == i._id}) {
                        print("repedito: \(i.lastName) + \(i.firstName)")
                    } else {
                        self.model.customers.append(i)
                    }
                }
                self._view.showSuccess()
            } catch {
                print(error)
                self._view.showError()
            }

        })
    }
    
    func loadImage(row: Int, customer: CustomerModel.Customer, completion: @escaping (String?) -> ()) {
        let path = "\(Paths.fullPersonalData):\(customer.thumbnailImage ?? ""):images"
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


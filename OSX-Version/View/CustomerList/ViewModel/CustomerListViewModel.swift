//
//  CustomerListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa

class CustomerListViewModel: CustomerListViewModelContract {
    var imageCache = NSCache<AnyObject, AnyObject>()
  
    var model: CustomerListModel!
    var _view : CustomerListViewContract!
    
    required init(withView view: CustomerListViewContract) {
        self._view = view
        self.model = CustomerListModel()
    }
    
    func loadCustomers(offset: Int) {
        _view.showLoading()
        let url = "http://127.0.0.1:2999/v1/customer?offset=\(offset)&limit=50"
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
                self._view.showError()
            }

        })
    }
    
    func loadImage(row: Int, customer: CustomerModel.Customer, completion: @escaping (NSImage?, Int) -> ()) {
        let url = "http://127.0.0.1:2999/v1/thumbnail?uid=\(customer.uid)"
        
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            print("loaded from cache")
            completion(imageFromCache, row)
            return
        }
        
        let _services = NetwordManager()
        _services.get(url: url, response: { (data, error) in
            guard error == nil, let data = data else {
                completion(nil, row)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ThumbnailModel.Response.self, from: data)
                if response.thumbnails.count > 0 {
                    let image = response.thumbnails[0].thumbnailImage.convertToImage
                    self.imageCache.setObject(image!, forKey: url as AnyObject)
                    completion(image, row)
                } else {
                    completion(nil, row)
                }
            } catch {
                completion(nil, row)
            }
      })
    }
    
    func getTotalItems() -> Int {
        return model.response?.total_amount ?? 0
    }
}


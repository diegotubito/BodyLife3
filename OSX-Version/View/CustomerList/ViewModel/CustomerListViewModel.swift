//
//  CustomerListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Cocoa
import BLServerManager

class CustomerListViewModel: CustomerListViewModelContract {
    var loading = false
    var imageCache = NSCache<AnyObject, AnyObject>()
   
    var model: CustomerListModel!
    var _view : CustomerListViewContract!
    
    required init(withView view: CustomerListViewContract) {
        self._view = view
        self.model = CustomerListModel()
    }
    
    func loadCustomers(bySearch: String, offset: Int) {
        if model.stopLoading {
            return
        }
       
        if offset == 0 {
            model.customersbySearch.removeAll()
        }
        _view.showLoading()
        
        let query = "?queryString=\(bySearch)&offset=\(offset)&limit=50"
        let stringQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let endpoint = Endpoint.Create(to: .Customer(.Search(query: stringQuery!)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[CustomerModel.Customer]>) in
            self._view.hideLoading()
            self.loading = false
            self.model.customersbySearch.append(contentsOf: response.data!)
            self.loadImages()
            self._view.showSuccess()
            if response.data!.count < 50 {
                self.model.stopLoading = true
            }
           
        } fail: { (error) in
            self._view.hideLoading()
            self.loading = false
            self._view.showError()
        }
    }
    
    func loadCustomers(offset: Int) {
        if model.stopLoading {
            return
        }
        if offset == 0 {
            model.customersbyPages.removeAll()
        }
    
        if loading {return}
        loading = true
        _view.showLoading()
        let query = "?offset=\(offset)&limit=50"
        let endpoint = Endpoint.Create(to: .Customer(.LoadPage(query: query)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[CustomerModel.Customer]>) in
            self._view.hideLoading()
            self.loading = false
            self.model.customersbyPages.append(contentsOf: response.data!)
            self.loadImages()
            self._view.showSuccess()
            if response.data!.count < 50 {
                self.model.stopLoading = true
            }
        } fail: { (error) in
            self._view.hideLoading()
            self.loading = false
            self._view.showError()
        }
    }
    
    func loadImages() {
        let customers = model.bySearch ? model.customersbySearch : model.customersbyPages

        for (x,customer) in customers.enumerated() {
            
            self.loadImage(row: x, customer: customer)
            
        }
    }
  
    func loadImage(row: Int, customer: CustomerModel.Customer) {
      
        self.loadImage(row: row, customer: customer) { (image, correctRow) in
            let newImage = CustomerListModel.Images(image: image, _id: customer._id)
            if self.model.bySearch {
                self.model.imagesBySearch.append(newImage)
            } else {
                self.model.imagesByPages.append(newImage)
            }
            self._view.reloadCell(row: row)
        }
    }
    
    
    func loadImage(row: Int, customer: CustomerModel.Customer, completion: @escaping (NSImage?, Int) -> ()) {
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail?uid=\(customer.uid)"
        
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            completion(imageFromCache, row)
            return
        }
        
        let uid = customer._id
        let endpoint = Endpoint.Create(to: .Image(.LoadThumbnail(_id: uid)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<ThumbnailModel.Thumbnail>) in
            guard let imageDowloaded = response.data else {
                completion(nil, row)
                return
            }
            let image = imageDowloaded.thumbnailImage.convertToImage
            self.imageCache.setObject(image!, forKey: url as AnyObject)
            completion(image, row)
        } fail: { (error) in
            completion(nil, row)
        }
    }
  
    func setImageForCustomer(_id: String, thumbnail: String) {
        let image = thumbnail.convertToImage
        if let position = model.imagesByPages.firstIndex(where: {$0._id == _id}) {
            model.imagesByPages[position].image = image
           
        }
        if let position = model.imagesBySearch.lastIndex(where: {$0._id == _id}) {
            model.imagesBySearch[position].image = image
            
        }
        self._view.reloadList()
        
        
    }
    
}


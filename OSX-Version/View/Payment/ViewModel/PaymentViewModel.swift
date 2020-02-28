//
//  PaymentViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class PaymentViewModel: PaymentViewModelContract {
    var _view : PaymentViewContract!
    var model : PaymentModel!
    
    required init(withView view: PaymentViewContract) {
        _view = view
        model = PaymentModel()
    }
    
    func setSelectedInfo(_ customer: CustomerModel, _ register: SellRegisterModel) {
        model.selectedCustomer = customer
        model.selectedSellRegister = register
        _view.displayInfo()
    }
   
    func saveNewPayment() {
        _view.showLoading()
        let childIDCustomer = model.selectedCustomer.childID
        let childIDRegister = model.selectedSellRegister.childID
        let price = Double(_view.getAmountString())!
        var error : ServerError?
        let semasphore = DispatchSemaphore(value: 0)
        
        let pathNewPayment = "\(Paths.fullPersonalData):\(childIDCustomer):sells:\(childIDRegister):payments"
        let request = createRequest()
        ServerManager.Update(path: pathNewPayment, json: request) { (data, err) in
           error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError()
            return
        }
        
        
        let pathNewPayment2 = Paths.payments
        ServerManager.Update(path: pathNewPayment2, json: request) { (data, err) in
           error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError()
            return
        }
        
        
        
        let pathStatus = "\(Paths.customerStatus):\(childIDCustomer)"
        ServerManager.Transaction(path: pathStatus, key: "balance", value: price, success: {
            semasphore.signal()
        }) { (err) in
            error = err
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError()
            return
        }
        
        _view.showSuccess()
        _view.hideLoading()
        
    }
    
    func createRequest() -> [String:Any] {
        let childIDCustomer = model.selectedCustomer.childID
        let childIDRegister = model.selectedSellRegister.childID
         
        let newChildID = ServerManager.createNewChildID()
        let data = ["childID" : newChildID,
                    "childIDCustomer" : childIDCustomer,
                    "childIDSell" : childIDRegister,
                    "createAt" : Date().timeIntervalSinceReferenceDate,
                    "isEnabled" : true,
                    "amount" : Double(self._view.getAmountString())!] as [String : Any]
        
        
        let json = [newChildID : data]
        return json
    }
    
}

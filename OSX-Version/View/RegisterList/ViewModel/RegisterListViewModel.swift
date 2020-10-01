//
//  RegisterListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListViewModel: RegisterListViewModelContract {
    
    var _view : RegisterListViewContract!
    var model : RegisterListModel!
    
    required init(withView view: RegisterListViewContract) {
        _view = view
        model = RegisterListModel()
    }
    
    func loadData() {
        _view.showLoading()
        setSelectedRegister(nil)
        
        let uid = ImportDatabase.codeUID(model.selectedCustomer.uid)
        
        let url = "http://127.0.0.1:2999/v1/sell?customer=\(uid)"
        self.model.response = nil
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            self._view.hideLoading()
            guard let data = data else {
               
                return
            }
            do {
            
                let response = try JSONDecoder().decode(RegisterListModel.Response.self, from: data)
                self.model.response = response
                
                
                self.loadPayments()
            } catch {
                print("could not decode")
                return
            }
        }
        
    }
    
    func loadPayments() {
        _view.showLoading()
        
        let uid = ImportDatabase.codeUID(model.selectedCustomer.uid)
        
        let url = "http://127.0.0.1:2999/v1/payment?customer=\(uid)"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            self._view.hideLoading()
            guard let data = data else {
               
                return
            }
            do {
                let response = try JSONDecoder().decode(PaymentModel.ViewModel.self, from: data)
                self.calcExtras(payments: response.payments)
                self._view.displayData()
            } catch {
                print("could not decode")
                return
            }
        }
        
    }
    
    private func calcExtras(payments: [PaymentModel.ViewModel.AUX]) {
        guard let sells = model.response?.sells else {
            return
        }
        let sorted = sells.sorted(by: {$0.timestamp > $1.timestamp})
        model.response?.sells = sorted
        for (x,sell) in sorted.enumerated() {
            let amountToPay = sell.price
            let correctPayments = payments.filter({$0.self.sell._id == sell._id})
    
            let totalPayments = calcTotalPayment(payments: correctPayments)
            let balance = totalPayments - amountToPay
            
            model.response?.sells[x].totalPayment = totalPayments
            model.response?.sells[x].balance = balance
        }
    }
    
    private func calcTotalPayment(payments: [PaymentModel.ViewModel.AUX]) -> Double {
        var total : Double = 0
        for i in payments {
            total += i.paidAmount
        }
        
        return total
    }
    
    func setSelectedCustomer(customer: CustomerModel.Customer) {
        model.selectedCustomer = customer
        model.response = nil
        _view.displayData()
    }
    
    func getRegisters() -> RegisterListModel.Response? {
        return model.response
    }
    
    func setSelectedRegister(_ selectedRegister: RegisterListModel.ViewModel?) {
        model.selectedSellRegister = selectedRegister
        DispatchQueue.main.async {
            self._view.updateButtonState()
        }
    }
    
    func getSelectedRegister() -> RegisterListModel.ViewModel? {
        return model.selectedSellRegister
    }
    
    func cancelRegister() {
        cancel { (success) in
            
            success == true ? self._view.cancelSuccess() : self._view.cancelError()
        }
    }
    
    func cancel(completion: (Bool) -> ()) {
       /* let json = ["isEnabled" : false]
        var error : ServerError?
        let semasphore = DispatchSemaphore(value: 0)
        
        if let childIDArticle = model.selectedSellRegister.childIDArticle {
            updateStockAndSellcount(childIDArticle)
        }
        if let childIDActivity = model.selectedSellRegister.childIDPeriod {
            updateSellcountForActivity(childIDActivity)
        }
        
        
        let pathSell = "\(Paths.registers):\(model.selectedSellRegister.childID)"
        ServerManager.Update(path: pathSell, json: json) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathCustomerSell = "\(Paths.fullPersonalData):\(model.selectedCustomer.uid):sells:\(model.selectedSellRegister.childID)"
        ServerManager.Update(path: pathCustomerSell, json: json) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathStatus = "\(Paths.customerStatus):\(model.selectedCustomer.uid)"
        let paid = calcTotalPayments()
        let amount = model.selectedSellRegister.amount
        let balance = amount - paid
        ServerManager.Transaction(path: pathStatus, key: "balance", value: balance, success: {
            semasphore.signal()
        }) { (err) in
            error = err
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        */
        completion(true)
 
 
    }
    
    private func calcTotalPayments() -> Double {
     /*   var result : Double = 0
        let payments = model.selectedSellRegister.pay
        if payments == nil {return 0}
        for i in payments {
            result += i.amount
        }
        return result
 */
        return 0.0
    }
    
    private func updateStockAndSellcount(_ childIDArticle: String) {
        print("stock updated")
        let pathArticleSellCount = "\(Paths.productArticle):\(childIDArticle)"
        ServerManager.Transaction(path: pathArticleSellCount, key: "sellCount", value: -1, success: {
        }) { (err) in
         
        }
        
        let pathArticleStock = "\(Paths.productArticle):\(childIDArticle)"
        ServerManager.Transaction(path: pathArticleStock, key: "stock", value: 1, success: {
        }) { (err) in
         
        }
    }
    
    private func updateSellcountForActivity(_ childIDActivity: String) {
        let pathArticleSellCount = "\(Paths.productService):activity:\(childIDActivity)"
        ServerManager.Transaction(path: pathArticleSellCount, key: "sellCount", value: -1, success: {
        }) { (err) in
            
        }
    }
    
    func setIsEnabled(row: Int) {
        model.response?.sells[row].isEnabled = false
    }
}

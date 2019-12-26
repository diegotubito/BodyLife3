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
        model.registers.removeAll()
        let path = Paths.customerFull + ":personal:\(model.selectedCustomer.childID):sells"
        ServerManager.ReadJSON(path: path) { (json, error) in
            self._view.hideLoading()
            
            guard let json = json else {
                self._view.displayData()
                return
            }
            
            var jsonArray = ServerManager.jsonArray(json: json)
            for (x,register) in jsonArray.enumerated() {
                if let payments = register["payments"] {
                    let paymentJSONArray = ServerManager.jsonArray(json: payments as! [String : Any])
                    jsonArray[x]["payments"] = paymentJSONArray
                }
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let registers = try JSONDecoder().decode([SellRegisterModel].self, from: data)
                let sortedRegisters = registers.sorted(by: { $0.createdAt > $1.createdAt })
                self.model.registers = sortedRegisters
                self.calcExtras()
                
                
                self._view.displayData()
                
            } catch {
                self._view.showError(value: error.localizedDescription)
            }
        }
    }
    
    private func calcExtras() {
        for (x,register) in model.registers.enumerated() {
            let price = register.price
            let totalPayments = calcTotalPayment(payments: register.payments)
            let saldo = totalPayments - price
            
            model.registers[x].totalPayment = totalPayments
            model.registers[x].balance = saldo
        }
    }
    
    private func calcTotalPayment(payments: [PaymentModel]?) -> Double {
        if payments == nil {return 0}
        var total : Double = 0
        for i in payments! {
            total += i.total
        }
        
        return total
    }
    
    func setSelectedCustomer(customer: CustomerModel) {
        model.selectedCustomer = customer
        model.registers.removeAll()
        _view.displayData()
    }
    
    func getRegisters() -> [SellRegisterModel] {
        return model.registers
    }
    
    func setSelectedRegister(_ selectedRegister: SellRegisterModel?) {
        model.selectedSellRegister = selectedRegister
        _view.updateButtonState()
    }
    
    func getSelectedRegister() -> SellRegisterModel? {
        return model.selectedSellRegister
    }
    
    func cancelRegister() {
        cancel { (success) in
            
            success == true ? self._view.cancelSuccess() : self._view.cancelError()
        }
    }
    
    func cancel(completion: (Bool) -> ()) {
        let json = ["isEnabled" : false]
        var error : ServerError?
        let semasphore = DispatchSemaphore(value: 0)
        
        if let childIDArticle = model.selectedSellRegister.childIDArticle {
            updateStockAndSellcount(childIDArticle)
        }
        if let childIDActivity = model.selectedSellRegister.childIDPeriod {
            updateSellcountForActivity(childIDActivity)
        }
        
        
        let pathSell = "\(Paths.sells):\(model.selectedSellRegister.childID)"
        ServerManager.Update(path: pathSell, json: json) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathCustomerSell = "\(Paths.fullPersonalData):\(model.selectedCustomer.childID):sells:\(model.selectedSellRegister.childID)"
        ServerManager.Update(path: pathCustomerSell, json: json) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathStatus = "\(Paths.customerStatus):\(model.selectedCustomer.childID)"
        ServerManager.Transaction(path: pathStatus, key: "transaction", value: model.selectedSellRegister.price, success: {
            semasphore.signal()
        }) { (err) in
            error = err
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        completion(true)
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
        model.registers[row].isEnabled = false
    }
}

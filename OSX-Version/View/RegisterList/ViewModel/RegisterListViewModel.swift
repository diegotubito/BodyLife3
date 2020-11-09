//
//  RegisterListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class RegisterListViewModel: RegisterListViewModelContract {
   
    
    var _view : RegisterListViewContract!
    var model : RegisterListModel!
    
    required init(withView view: RegisterListViewContract) {
        _view = view
        model = RegisterListModel()
    }
    
    func loadPayments() {
        _view.showLoading()
        model.sells.removeAll()
        model.payments.removeAll()
    
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment?customer=\(model.selectedCustomer._id)"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
 
            guard let data = data else {
                self._view.hideLoading()
                self._view.showError(value: error?.localizedDescription ?? ServerError.unknown_auth_error.localizedDescription)
                return
            }
            do {
                let response = try JSONDecoder().decode(PaymentModel.ViewModel.self, from: data)
                self.parsePaymentAndSell(response: response)
            } catch {
                print("Could not parse")
                return
            }
        }
    }
    
    
    func parsePaymentAndSell(response : PaymentModel.ViewModel) {
        let sells = response.payments.compactMap { $0.sell }
        
        var uniqueArray = [SellModel.NewRegister]()
        for i in sells {
            if !uniqueArray.contains(where: {$0._id == i._id}) {
                uniqueArray.append(i)
            }
        }
        let sortedSells = uniqueArray.sorted(by: { $0.timestamp > $1.timestamp })
        model.sells = sortedSells
        
        let sortedPayments = response.payments.sorted(by: {$0.timestamp > $1.timestamp})
        model.payments = sortedPayments
    
        calcExtras(payments: model.payments)
    }
    
    func calcExtras(payments: [PaymentModel.ViewModel.AUX]) {
        let sells = model.sells
        var totalSells : Double = 0
        var totalPayments : Double = 0
        var maxExpiration = "01-01-2001".toDate(formato: "dd-MM-yyyy")!
        var lastActivity : String?
        var lastPeriod : String?
        var lastDiscount : String?
        
        for (x,sell) in sells.enumerated() {
            let amountToPay = sell.price
            
            let correctPayments = payments.filter({$0.self.sell._id == sell._id})
            
            let partialPayments = calcTotalPayment(payments: correctPayments)
            let balance = partialPayments - (amountToPay ?? 0)
            
            if let toDate = sell.toDate?.toDate1970 {
                if toDate > maxExpiration && sell.isEnabled {
                    maxExpiration = toDate
                    lastActivity = sell.activity
                    lastDiscount = sell.discount
                    lastPeriod = sell.period
                }
            }
            model.sells[x].totalPayment = partialPayments
            model.sells[x].balance = balance
            if sell.isEnabled {
                totalSells += amountToPay ?? 0
                totalPayments += partialPayments
            }
        }
        
        let statusInfo = CustomerStatusModel.StatusInfo(expiration: maxExpiration,
                                                        balance: totalPayments - totalSells,
                                                        customer: model.selectedCustomer,
                                                        lastActivityId: lastActivity,
                                                        lastPeriodId: lastPeriod,
                                                        lastDiscountId: lastDiscount)
        self._view.notificateStatusInfo(data: statusInfo)
        self._view.hideLoading()
        self._view.displayData()
  
    }
   
    
    private func calcTotalPayment(payments: [PaymentModel.ViewModel.AUX]) -> Double {
        var total : Double = 0
        for i in payments {
            if i.isEnabled {
                total += i.paidAmount
            }
        }
        
        return total
    }
    
    func setSelectedCustomer(customer: CustomerModel.Customer) {
        model.selectedCustomer = customer
        model.sells.removeAll()
        model.payments.removeAll()
        _view.displayData()
    }
    
    func getSells() -> [SellModel.NewRegister] {
        return model.sells
    }

    func getPayments() -> [PaymentModel.ViewModel.AUX] {
        return model.payments
    }
    
    func getPaymentsForSelectedRegister() -> [PaymentModel.ViewModel.AUX] {
        let payments = model.payments
        let filter = payments.filter({$0.sell._id == model.selectedSellRegister?._id})
        return filter
    }

    func setSelectedRegister(_ selectedRegister: SellModel.NewRegister?) {
        model.selectedSellRegister = selectedRegister
        DispatchQueue.main.async {
            self._view.updateButtonState()
        }
    }
    
    func getSelectedRegister() -> SellModel.NewRegister? {
        return model.selectedSellRegister
    }
    
    func cancelRegister() {
        let json = ["isEnabled" : false]
        
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell?id=\((model.selectedSellRegister?._id)!)"
        
        let _service = NetwordManager()
        _service.update(url: url, body: json, response: { (data, error) in
            guard data != nil else {
                self._view.cancelError()
                return
            }
            self._view.cancelSuccess()
        })
    }
    
    func realDeleteEveryRelatedSellAndPayment() {
        let json = ["isEnabled" : false]
        
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/sell?id=\((model.selectedSellRegister?._id)!)"
        
        let _service = NetwordManager()
        _service.delete(url: url, body: json, response: { (data, error) in
            guard data != nil else {
                self._view.cancelError()
                return
            }
            self._view.cancelSuccess()
        })
        
        
        for i in model.payments {
            
            if i.sell._id == (model.selectedSellRegister?._id)! {
                let json = ["isEnabled" : false]
                
                let url = "\(BLServerManager.baseUrl.rawValue)/v1/payment?id=\(i._id)"
                
                let _service = NetwordManager()
                _service.delete(url: url, body: json, response: { (data, error) in
                    guard data != nil else {
                        self._view.cancelError()
                        return
                    }
                    self._view.cancelSuccess()
                })
            }

        }
 
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
        model.sells[row].isEnabled = false
    }
    
}

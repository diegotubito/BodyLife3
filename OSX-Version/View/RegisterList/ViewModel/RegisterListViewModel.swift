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
    
    func loadPayments() {
        _view.showLoading()
        
        let url = "http://127.0.0.1:2999/v1/payment?customer=\(model.selectedCustomer._id)"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            
            guard let data = data else {
               
                return
            }
            do {
                let response = try JSONDecoder().decode(PaymentModel.ViewModel.self, from: data)
                self.parsePaymentAndSell(response: response)
            } catch {
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
    
    private func calcExtras(payments: [PaymentModel.ViewModel.AUX]) {
        let sells = model.sells
        var totalSells : Double = 0
        var totalPayments : Double = 0
        var maxExpiration = "01-01-2001".toDate(formato: "dd-MM-yyyy")!
        var lastActivity : String?
        var lastPeriod : String?
        var lastDiscount : String?
        
        let sorted = sells.sorted(by: {$0.timestamp > $1.timestamp})
        let filterSells = sorted.filter({$0.isEnabled == true})
        model.sells = sorted
        for (x,sell) in filterSells.enumerated() {
            let amountToPay = sell.price
            
            let correctPayments = payments.filter({$0.self.sell._id == sell._id && $0.isEnabled == true})
            
            let partialPayments = calcTotalPayment(payments: correctPayments)
            let balance = partialPayments - (amountToPay ?? 0)
            
            if let toDate = sell.toDate?.toDate1970 {
                if toDate > maxExpiration {
                    maxExpiration = toDate
                    lastActivity = sell.activity
                    lastDiscount = sell.discount
                    lastPeriod = sell.period
                }
            }
            model.sells[x].totalPayment = partialPayments
            model.sells[x].balance = balance
            totalSells += amountToPay ?? 0
            totalPayments += partialPayments
            print("\(lastDiscount) lastDiscount")
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
            total += i.paidAmount
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
        model.sells[row].isEnabled = false
    }
    
}

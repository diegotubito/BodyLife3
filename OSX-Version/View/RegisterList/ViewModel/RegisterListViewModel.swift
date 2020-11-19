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
        let customerId = model.selectedCustomer._id
        let endpoint = Endpoint.Create(to: .Payment(.Load(customerId: customerId)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[PaymentModel.NewRegister]>) in
            
            self.parsePaymentAndSell(payments: response.data!)
        } fail: { (error) in
            self._view.notificateStatusInfo(data: nil)
        }
    }
    
    
    func parsePaymentAndSell(payments : [PaymentModel.NewRegister]) {
        let sells = payments.compactMap { $0.sell }
        
        var uniqueArray = [SellModel.NewRegister]()
        for i in sells {
            if !uniqueArray.contains(where: {$0._id == i._id}) {
                uniqueArray.append(i)
            }
        }
        let sortedSells = uniqueArray.sorted(by: { $0.timestamp > $1.timestamp })
        model.sells = sortedSells
        
        let sortedPayments = payments.sorted(by: {$0.timestamp > $1.timestamp})
        model.payments = sortedPayments
    
        calcExtras(payments: model.payments)
    }
    
    func calcExtras(payments: [PaymentModel.NewRegister]) {
        let sells = model.sells
        var totalSells : Double = 0
        var totalPayments : Double = 0
        var maxExpiration = "11-11-2004".toDate(formato: "dd-MM-yyyy")!
        var lastActivity : String?
        var lastPeriod : String?
        var lastDiscount : String?
        
        for (x,sell) in sells.enumerated() {
            
            let amountToPay = sell.price
            
            let correctPayments = payments.filter({$0.self.sell?._id == sell._id})
            
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
   
    
    private func calcTotalPayment(payments: [PaymentModel.NewRegister]) -> Double {
        var total : Double = 0
        for i in payments {
            if i.isEnabled {
                total += i.paidAmount
            }
        }
        
        return total
    }
    
    func setSelectedCustomer(customer: CustomerModel.Customer?) {
        model.selectedCustomer = customer
        model.sells.removeAll()
        model.payments.removeAll()
        _view.displayData()
    }
    
    func getSells() -> [SellModel.NewRegister] {
        return model.sells
    }

    func getPayments() -> [PaymentModel.NewRegister] {
        return model.payments
    }
    
    func getPaymentsForSelectedRegister() -> [PaymentModel.NewRegister] {
        let payments = model.payments
        let filter = payments.filter({$0.sell?._id == model.selectedSellRegister?._id})
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
        let body = ["isEnabled" : false]
        guard let uid = (model.selectedSellRegister?._id) else {return}
        let endpoint = Endpoint.Create(to: .Sell(.Disable(uid: uid, body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<SellModel.NewRegister>) in
            self._view.cancelSuccess()
            if let articleID = self.model.selectedSellRegister?.article {
                self.updateStock(articleID)
            }
        } fail: { (error) in
            self._view.cancelError()
        }
    }
    
    func realDeleteEveryRelatedSellAndPayment() {
        guard let uid = model.selectedSellRegister?._id else {return}
        let endpoint = Endpoint.Create(to: .Sell(.Delete(uid: uid)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<SellModel.NewRegister>) in
            response.success ?? false ? self._view.cancelSuccess() : self._view.cancelError()
        } fail: { (error) in
            self._view.cancelError()
        }

        for i in model.payments {
            if i.sell?._id == (model.selectedSellRegister?._id)! {
                let uid = i._id
                let endpoint = Endpoint.Create(to: .Payment(.Delete(uid: uid)))
                BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<PaymentModel.Response>) in
                    response.success ?? false ? self._view.cancelSuccess() : self._view.cancelError()
                } fail: { (error) in
                    self._view.cancelError()
                }
            }

        }
 
    }
    
    private func updateStock(_ childIDArticle: String) {
        let path = "product:article:\(childIDArticle)"
        let uid = UserSaved.GetUser()?.uid
        let endpoint = Endpoint.Create(to: .Transaction(uid: uid!,
                                                                      path: path,
                                                                      key: "stock",
                                                                      value: 1))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: Bool) in
            print("stock updated")
            NotificationCenter.default.post(.init(name: .needUpdateArticleList))
        } fail: { (error) in
            print("could not update stock")
        }
    }
    
    func setIsEnabled(row: Int) {
        model.sells[row].isEnabled = false
    }
    
    func initValues() {
        model.selectedCustomer = nil
        model.selectedSellRegister = nil
        model.payments.removeAll()
        model.sells.removeAll()
        _view.updateButtonState()
        _view.displayData()
    }
    
}

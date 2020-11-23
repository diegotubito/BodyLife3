//
//  PaymentViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class PaymentViewModel: PaymentViewModelContract {
   
    
    var _view : PaymentViewContract!
    var model : NewPaymentModel!
    
    required init(withView view: PaymentViewContract) {
        _view = view
        model = NewPaymentModel()
    }
    
    func setSelectedInfo(_ customer: CustomerModel.Customer, _ register: SellModel.Register, payments: [PaymentModel.Populated]) {
        model.selectedCustomer = customer
        model.selectedSellRegister = register
        model.payments = payments
        _view.displayInfo()
    }
   
    func saveNewPayment() {
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = model.selectedCustomer._id!
        let sellId = model.selectedSellRegister._id ?? ""
        let paidAmount = Double(self._view.getAmountString())!
        let productCategory = model.selectedSellRegister.productCategory

        let newRegister = PaymentModel.Register(customer: customerId,
                                                sell: sellId,
                                                isEnabled: true,
                                                timestamp: createdAt,
                                                paidAmount: paidAmount,
                                                productCategory: productCategory)
        
        let body = encodePayment(newRegister)
        let endpoint = Endpoint.Create(to: .Payment(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<PaymentModel.Register>) in
            self._view.hideLoading()
            self._view.showSuccess()
        } fail: { (error) in
            self._view.hideLoading()
            self._view.showError()
        }
    }
    
    private func encodePayment(_ register: PaymentModel.Register) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
}

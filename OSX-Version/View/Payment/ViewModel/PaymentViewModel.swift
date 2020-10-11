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
    var model : NewPaymentModel!
    
    required init(withView view: PaymentViewContract) {
        _view = view
        model = NewPaymentModel()
    }
    
    func setSelectedInfo(_ customer: CustomerModel.Customer, _ register: SellModel.NewRegister, payments: [PaymentModel.ViewModel.AUX]) {
        model.selectedCustomer = customer
        model.selectedSellRegister = register
        model.payments = payments
        _view.displayInfo()
    }
   
    func saveNewPayment() {
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = model.selectedCustomer._id
        let sellId = model.selectedSellRegister._id ?? ""
        let paidAmount = Double(self._view.getAmountString())!
        let productCategory = model.selectedSellRegister.productCategory

        let newRegister = PaymentModel.Response(customer: customerId,
                                                sell: sellId,
                                                isEnabled: true,
                                                timestamp: createdAt,
                                                paidAmount: paidAmount,
                                                productCategory: productCategory)
        
        let url = "\(Config.baseUrl.rawValue)/v1/payment"
        let _services = NetwordManager()
        let body = encodePayment(newRegister)
        _view.showLoading()
        _services.post(url: url, body: body) { (data, error) in
            self._view.hideLoading()
            guard data != nil else {
                print("No se puedo guardar pago")
                self._view.showError()
                return
            }
            self._view.showSuccess()
        }
    }
    
    private func encodePayment(_ register: PaymentModel.Response) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
}

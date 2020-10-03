//
//  RegisterListModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListModel {
    var selectedCustomer : CustomerModel.Customer!
    var selectedSellRegister : SellModel.NewRegister?
   
    var sells = [SellModel.NewRegister]()
    var payments = [PaymentModel.ViewModel.AUX]()
}

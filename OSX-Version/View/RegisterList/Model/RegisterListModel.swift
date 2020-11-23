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
    var selectedSellRegister : SellModel.Register?
   
    var sells = [SellModel.Register]()
    var payments = [PaymentModel.Populated]()
}

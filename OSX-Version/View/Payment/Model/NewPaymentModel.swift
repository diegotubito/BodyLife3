//
//  PaymentModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

class NewPaymentModel {
    var selectedCustomer : CustomerModel.Customer!
    var payments : [PaymentModel.ViewModel.AUX]!
    var selectedSellRegister : SellModel.NewRegister!
}

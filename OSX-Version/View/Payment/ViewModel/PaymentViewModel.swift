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
    
    required init(withView view: PaymentViewContract) {
        _view = view
    }
    
    
}

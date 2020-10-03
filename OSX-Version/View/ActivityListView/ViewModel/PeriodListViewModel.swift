//
//  ActivityListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class PeriodListViewModel:  PeriodListViewModelContract {
    var _view : PeriodListViewContract!
    var model: PeriodListModel!
    
    required init(withView view: PeriodListViewContract) {
        _view = view
        model = PeriodListModel()
    }
}

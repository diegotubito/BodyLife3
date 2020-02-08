//
//  ActivityListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivityListViewModel:  ActivityListViewModelContract {
    var _view : ActivityListViewContract!
    var model: ActivityListModel!
    
    required init(withView view: ActivityListViewContract) {
        _view = view
        model = ActivityListModel()
    }
}

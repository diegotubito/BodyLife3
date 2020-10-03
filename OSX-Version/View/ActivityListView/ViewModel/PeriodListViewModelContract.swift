//
//  ActivityListViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol PeriodListViewModelContract {
    init(withView view: PeriodListViewContract)
}

protocol PeriodListViewContract {
    func displayList()
    func showError()
    func showLoading()
    func hideLoading()
}

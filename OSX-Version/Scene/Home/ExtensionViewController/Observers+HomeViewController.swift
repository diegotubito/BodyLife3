//
//  Observers+HomeViewController.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa


extension HomeViewController {
    
    func addObservers() {
        customerListOberserver()
        buttonObserverProductSell()
        buttonObserverActivitySell()
        buttonObserverPayment()
    }
    
    func customerListOberserver() {
        self.customerListView.onSelectedCustomer = { customer in
//            self.selectedCustomer = customer
//            self.timerForDelayCustomerSelection.invalidate()
//            self.customerStatusView.showLoading()
//            self.customerStatusView.titleLabel.stringValue = customer.surname + ", " + customer.name
//            self.sellRegisterView.setSelectedCustomer(customer: customer)
//            self.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
//            if self.sellRegisterView.isHidden {
//                self.sellRegisterView.animateMode = .fadeIn
//            }
        }
    }
    
    func buttonObserverActivitySell() {
        self.customerStatusView.didPressSellActivityButton = {
            //open sell activities custom view
            let selectedCustomer = self.customerListView.viewModel.model.selectedCustomer
            let loadedStatus = self.customerStatusView.viewModel.model.loadedStatus
//            self.sellActivityView.viewModel.setCustomerStatus(selectedCustomer: selectedCustomer!, selectedStatus: loadedStatus)
            self.sellActivityView.showView()
        }
    }
    
    func buttonObserverProductSell() {
        self.customerStatusView.didPressSellProductButton = {
            self.sellProductView.selectedCustomer = (self.selectedCustomer)!
            self.sellProductView.showView()
        }
    }
    
    func buttonObserverPayment() {
        self.sellRegisterView.onAddPayment = {
            self.paymentView.viewmodel.setSelectedInfo(self.selectedCustomer!, self.sellRegisterView.viewModel.getSelectedRegister()!)
            self.paymentView.showView()
        }
    }
    
    func showStatusCustomer() {
        if self.customerStatusView.isHidden {
            self.customerStatusView.animateMode = .fadeIn
        }
    }
    
    func showSellRegister() {
        if self.sellRegisterView.isHidden {
            self.sellRegisterView.animateMode = .leftIn
        }
    }

    
    func didSelectCustomer(customerSelected: BriefCustomer) {
        DispatchQueue.main.async {
            self.showStatusCustomer()
            self.customerStatusView.viewModel = CustomerStatusViewModel(withView: self.customerStatusView, receivedCustomer: customerSelected)
            self.customerStatusView.start()
            self.showSellRegister()
            self.sellRegisterView.viewModel.loadData()
        }
    }
}

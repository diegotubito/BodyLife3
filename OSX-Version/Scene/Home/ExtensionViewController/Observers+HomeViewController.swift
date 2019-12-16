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
        activityButtonObserver()
        paymentButtonObserver()
    }
    
    func customerListOberserver() {
        self.customerListView.onSelectedCustomer = { customer in
            self.sellActivityView.animateMode = .fadeOut
            self.selectedCustomer = customer
            self.timerForDelayCustomerSelection.invalidate()
            self.customerStatusView.showLoading()
            self.customerStatusView.titleLabel.stringValue = customer.surname + ", " + customer.name
            self.sellRegisterView.setSelectedCustomer(customer: customer)
            self.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
            if self.sellRegisterView.isHidden {
                self.sellRegisterView.animateMode = .fadeIn
            }
        }
    }
    
    func activityButtonObserver() {
        self.customerStatusView.didPressSellActivityButton = {
            //open sell activities custom view
            self.sellActivityView.animateMode = .fadeIn
            self.sellActivityView.removeErrorConnectionView()
            let selectedCustomer = self.customerListView.viewModel.model.selectedCustomer
            let loadedStatus = self.customerStatusView.viewModel.model.loadedStatus
            self.sellActivityView.viewModel.setCustomerStatus(selectedCustomer: selectedCustomer!, selectedStatus: loadedStatus)
            self.sellActivityView.startLoading()
        }
    }
    
    func paymentButtonObserver() {
        self.customerStatusView.didPressPaymentButton = {
            self.paymentView.isHidden = false
            self.paymentView.animateMode = .fadeIn
        }
    }
    
    func showStatusCustomer() {
        if self.customerStatusView.isHidden {
            self.customerStatusView.animateMode = .fadeIn
        }
    }
    
    func showSellRegister() {
        if self.sellRegisterView.isHidden {
            self.sellRegisterView.animateMode = .fadeIn
        }
    }
    
    func hideSellActivityView() {
        if !self.sellActivityView.isHidden {
            self.sellActivityView.animateMode = .none
        }
    }
    
    func hidePaymentView() {
        if !self.paymentView.isHidden {
            self.paymentView.animateMode = .fadeOut
        }
    }
    
    func didSelectCustomer(customerSelected: CustomerModel) {
        DispatchQueue.main.async {
            self.hideSellActivityView()
            self.hidePaymentView()
            self.showStatusCustomer()
            self.showSellRegister()
            
            self.customerStatusView.viewModel = CustomerStatusViewModel(withView: self.customerStatusView, receivedCustomer: customerSelected)
            self.customerStatusView.start()
        }
    }
}

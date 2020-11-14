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
        self.customerListView.onSelectedCustomer = { [weak self] customer in
            self?.selectedCustomer = customer
            self?.timerForDelayCustomerSelection.invalidate()
            self?.customerStatusView.showLoading()
            let age = customer.dob.toDate1970.age()
            self?.customerStatusView.ageLabel.stringValue = String(age) + " Años"
            self?.customerStatusView.titleLabel.stringValue = customer.lastName + ", " + customer.firstName
            self?.sellRegisterView.setSelectedCustomer(customer: customer)
            self?.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.25, target: self as Any, selector: #selector(self?.loadStatus), userInfo: nil, repeats: false)
            if ((self?.sellRegisterView.isHidden) != nil) {
                self?.sellRegisterView.animateMode = .fadeIn
            }
            
        }
    }
    
    func buttonObserverActivitySell() {
        self.customerStatusView.didPressSellActivityButton = { [weak self] in
            //open sell activities custom view
            let selectedCustomer = self?.customerListView.viewModel.model.selectedCustomer
            let loadedStatus = self?.customerStatusView.viewModel.model.loadedStatus
//            self.sellActivityView.viewModel.setCustomerStatus(selectedCustomer: selectedCustomer!, selectedStatus: loadedStatus)
            self?.sellActivityView.showView()
        }
    }
    
    func buttonObserverProductSell() {
        self.customerStatusView.didPressSellProductButton = { [weak self] in
            self?.sellProductView.selectedCustomer = (self?.selectedCustomer)!
            self?.sellProductView.showView()
        }
    }
    
    func buttonObserverPayment() {
        self.sellRegisterView.onAddPayment = { payments in
            self.paymentView.viewmodel.setSelectedInfo(self.selectedCustomer!, self.sellRegisterView.viewModel.getSelectedRegister()!, payments: payments)
            self.paymentView.showView()
        }
    }
    
    func showStatusCustomer() { 
        if self.customerStatusView.isHidden {
            self.customerStatusView.animateMode = .fadeIn
        }
    }
    
    func didSelectCustomer(customerSelected: CustomerModel.Customer) {
        DispatchQueue.main.async {
            self.showStatusCustomer()
            self.customerStatusView.viewModel = CustomerStatusViewModel(withView: self.customerStatusView, receivedCustomer: customerSelected)
            self.sellRegisterView.viewModel.loadPayments()
        }
    }
}

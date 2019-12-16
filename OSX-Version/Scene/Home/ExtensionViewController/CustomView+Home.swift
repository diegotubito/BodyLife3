//
//  CustomView+Home.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension HomeViewController {
    func createPaymentView() {
        paymentView = PaymentView(frame: CGRect(x: view.frame.width * 0.3, y: view.frame.height - 250, width: view.frame.width - (view.frame.width * 0.3), height: 250))
        view.addSubview(paymentView)
    }
    
    func createCustomerListView() {
        customerListView = CustomerListView(frame: NSRect(x: 0, y: 0, width: view.frame.width * 0.3, height: view.frame.height))
        view.addSubview(customerListView)
    }
    
    func createCustomerStatusView() {
        customerStatusView = CustomerStatusView(frame: CGRect(x: view.frame.width * 0.3, y: view.frame.height - 250, width: view.frame.width - (view.frame.width * 0.3), height: 250))
        view.addSubview(customerStatusView)
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
    
    func createSellActivityCustomView() {
        self.customerStatusView.animateMode = .fadeOut
        
        sellActivityView = SellActivityCustomView(frame: CGRect(x: view.frame.width * 0.3, y: 0, width: view.frame.width - (view.frame.width * 0.3), height: view.frame.height))
        self.view.addSubview(sellActivityView)
        
    }
    
    func createRegisterView() {
        
        sellRegisterView = RegisterListView(frame: CGRect(x: view.frame.width * 0.3, y: 250, width: view.frame.width - (view.frame.width * 0.3), height: 250))
        self.view.addSubview(sellRegisterView)
        
    }
    
    func addObservers() {
        customerListOberserver()
        activityButtonObserver()
        paymentButtonObserver()
    }
    
    func customerListOberserver() {
        self.customerListView.onSelectedCustomer = { customer in
            self.sellActivityView.animateMode = .fadeOut
            self.selectedCustomer = customer
            self.timer.invalidate()
            self.customerStatusView.showLoading()
            self.customerStatusView.titleLabel.stringValue = customer.surname + ", " + customer.name
            self.sellRegisterView.setSelectedCustomer(customer: customer)
            self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
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
    
}

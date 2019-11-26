//
//  CustomView+Home.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension HomeViewController {
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
            self.customerStatusView.didPressSellActivityButton = {
                //open sell activities custom view
                self.sellActivityView.animateMode = .fadeIn
                self.sellActivityView.removeErrorView()
                let selectedCustomer = self.customerListView.viewModel.model.selectedCustomer
                let loadedStatus = self.customerStatusView.viewModel.model.loadedStatus
                self.sellActivityView.viewModel.setCustomerStatus(selectedCustomer: selectedCustomer!, selectedStatus: loadedStatus)
                self.sellActivityView.startLoading()
            }
            if self.customerStatusView.isHidden {
                self.customerStatusView.animateMode = .fadeIn
            }
            if self.sellActivityView.isHidden == false {
                self.sellActivityView.animateMode = .fadeOut
            }
            
            self.customerStatusView.viewModel = CustomerStatusViewModel(withView: self.customerStatusView, receivedCustomer: customerSelected)
            self.customerStatusView.start()
        }
        
    }
    
    func createSellActivityCustomView() {
        self.customerStatusView.animateMode = .fadeOut
        
        sellActivityView = SellActivityCustomView(frame: CGRect(x: view.frame.width * 0.3, y: 0, width: view.frame.width - (view.frame.width * 0.3), height: view.frame.height))
        self.view.addSubview(sellActivityView)
    
    }
    
}

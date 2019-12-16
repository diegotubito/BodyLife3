//
//  CustomView+Home.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension HomeViewController {
    func createCustomViews() {
        createCustomerListView()
        customerListView.isHidden = false
      
        createCustomerStatusView()
        customerStatusView.isHidden = true
        
        createRegisterView()
        sellRegisterView.isHidden = true
        
        createSellActivityCustomView()
        sellActivityView.isHidden = true
        
        createPaymentView()
        paymentView.isHidden = true
    }
    
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
    
    func createSellActivityCustomView() {
        self.customerStatusView.animateMode = .fadeOut
        
        sellActivityView = SellActivityCustomView(frame: CGRect(x: view.frame.width * 0.3, y: 0, width: view.frame.width - (view.frame.width * 0.3), height: view.frame.height))
        self.view.addSubview(sellActivityView)
        
    }
    
    func createRegisterView() {
        
        sellRegisterView = RegisterListView(frame: CGRect(x: view.frame.width * 0.3, y: 250, width: view.frame.width - (view.frame.width * 0.3), height: 250))
        self.view.addSubview(sellRegisterView)
        
    }
    
}

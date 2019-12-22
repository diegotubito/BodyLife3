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
        
        createUpperView()
        
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
        
        createBottomView()
    }
    
    func createUpperView() {
        let upperView = NSView(frame: CGRect(x: 0, y: 0, width: containerUpperBar.frame.width, height: containerUpperBar.frame.height))
        containerUpperBar.addSubview(upperView)
        
        containerUpperBar.wantsLayer = true
        containerUpperBar.layer?.backgroundColor = Constants.Colors.Gray.almondFrost.cgColor
    }
    
    func createBottomView() {
        let bottomView = NSView(frame: CGRect(x: 0, y: 0, width: containerBottomBar.frame.width, height: containerBottomBar.frame.height))
        containerBottomBar.addSubview(bottomView)
        
        containerBottomBar.wantsLayer = true
    //    containerBottomBar.layer?.backgroundColor = Constants.Colors.Gray.gray21.cgColor
    }
    
    func createPaymentView() {
        paymentView = PaymentView(frame: CGRect(x: view.frame.width * 0.3, y: view.frame.height - 250, width: view.frame.width - (view.frame.width * 0.3), height: 250))
        view.addSubview(paymentView)
    }
    
    func createCustomerListView() {
        customerListView = CustomerListView(frame: NSRect(x: 0, y: 0, width: containerCustomerList.frame.width, height: containerCustomerList.frame.height))
        containerCustomerList.addSubview(customerListView)
        containerCustomerList.wantsLayer = true
        containerCustomerList.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func createCustomerStatusView() {
        customerStatusView = CustomerStatusView(frame: CGRect(x: 0, y: 0, width: containerStatus.frame.width, height: containerStatus.frame.height))
        containerStatus.addSubview(customerStatusView)
    }
    
    func createSellActivityCustomView() {
        self.customerStatusView.animateMode = .fadeOut
        
        sellActivityView = SellActivityCustomView(frame: CGRect(x: view.frame.width * 0.3, y: 0, width: view.frame.width - (view.frame.width * 0.3), height: view.frame.height))
        self.view.addSubview(sellActivityView)
        
    }
    
    func createRegisterView() {
        
        sellRegisterView = RegisterListView(frame: CGRect(x: 0, y: 0, width: containerSellRegisters.frame.width, height: containerSellRegisters.frame.height))
        self.containerSellRegisters.addSubview(sellRegisterView)
        
    }
    
}

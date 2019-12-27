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
        createBottomView()
        createArticleSellView()
        createPaymentView()
    }
    
    func createArticleSellView() {
        let ancho = view.frame.width * 0.40
        let alto = view.frame.height * 0.5
        sellProductView = ArticleSellView(frame: CGRect(x: -ancho + 5, y: 0, width: ancho, height: alto))
        sellProductView.destiny = CGPoint(x: 0, y: 0)
        sellProductView.closeWhenBackgroundIsTouch = true
        sellProductView.layer?.cornerRadius = 10
        view.addSubview(sellProductView)

    }
    
    
    func createUpperView() {
        containerUpperBar.wantsLayer = true
        containerUpperBar.layer?.backgroundColor = Constants.Colors.Gray.almondFrost.cgColor
    }
    
    func createBottomView() {
        let bottomView = NSView(frame: CGRect(x: 0, y: 0, width: containerBottomBar.frame.width, height: containerBottomBar.frame.height))
        containerBottomBar.addSubview(bottomView)
        
        containerBottomBar.wantsLayer = true
        //    containerBottomBar.layer?.backgroundColor = Constants.Colors.Gray.gray21.cgColor
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
        let ancho = view.frame.width * 0.6
        let alto = view.frame.height * 0.6
        sellActivityView = SellActivityCustomView(frame: CGRect(x: self.view.frame.width - 5, y: 0, width: ancho, height: alto))
        sellActivityView.destiny = CGPoint(x: self.view.frame.width - ancho, y: 0)
        sellActivityView.closeWhenBackgroundIsTouch = true
        sellActivityView.layer?.cornerRadius = 10
        self.view.addSubview(sellActivityView)
        
        
    }
    
    func createPaymentView() {
        let ancho = view.frame.width * 0.4
        let alto = view.frame.height * 0.5
        paymentView = PaymentView(frame: CGRect(x: self.view.frame.width - 5, y: 0, width: ancho, height: alto))
        paymentView.destiny = CGPoint(x: self.view.frame.width - ancho, y: 0)
        paymentView.closeWhenBackgroundIsTouch = true
        paymentView.layer?.cornerRadius = 10
        view.addSubview(paymentView)
    }
    
    func createRegisterView() {
        
        sellRegisterView = RegisterListView(frame: CGRect(x: 0, y: 0, width: containerSellRegisters.frame.width, height: containerSellRegisters.frame.height))
        self.containerSellRegisters.addSubview(sellRegisterView)
        
    }
    
}

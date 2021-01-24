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
        
        createSecondaryUserView()
        createStockTableView()
    }
    
    func createSecondaryUserView() {
        let secondaryUserView = SecondaryUserStatusView(frame: CGRect(x: 0, y: 0, width: self.secondaryUserStatusViewContainer.frame.width, height: self.secondaryUserStatusViewContainer.frame.height))
        self.secondaryUserStatusViewContainer.addSubview(secondaryUserView)
    }
    
    func createStockTableView() {
        if stockTableView != nil {
            stockTableView.removeFromSuperview()
        }
        let ancho = view.frame.width * 0.45
        let alto = view.frame.height * 0.45
        stockTableView = StockTableView(frame: CGRect(x: -ancho + 5, y: 0, width: ancho, height: alto))
        stockTableView.destiny = CGPoint(x: 0, y: 0)
        stockTableView.closeWhenBackgroundIsTouch = true
        stockTableView.layer?.cornerRadius = 10
        view.addSubview(stockTableView)

    }
    
    func createArticleSellView() {
        if sellProductView != nil {
            sellProductView.removeFromSuperview()
        }
        let ancho = view.frame.width * 0.45
        let alto = view.frame.height * 0.65
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
        if customerListView != nil {
            customerListView.removeFromSuperview()
        }
        customerListView = CustomerListView(frame: NSRect(x: 0, y: 0, width: containerCustomerList.frame.width, height: containerCustomerList.frame.height))
        containerCustomerList.addSubview(customerListView)
        containerCustomerList.wantsLayer = true
        containerCustomerList.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func createCustomerStatusView() {
        if customerStatusView != nil {
            customerStatusView.removeFromSuperview()
        }
        customerStatusView = CustomerStatusView(frame: CGRect(x: 0, y: 0, width: containerStatus.frame.width, height: containerStatus.frame.height))
        containerStatus.addSubview(customerStatusView)
    }
    
    func createSellActivityCustomView() {
        if sellActivityView != nil {
            sellActivityView.removeFromSuperview()
        }
        let ancho = view.frame.width * 0.7
        let alto = view.frame.height * 0.8
        sellActivityView = ActivitySaleView(frame: CGRect(x: self.view.frame.width - 5, y: 0, width: ancho, height: alto))
        sellActivityView.destiny = CGPoint(x: self.view.frame.width - ancho, y: 0)
        sellActivityView.closeWhenBackgroundIsTouch = true
        sellActivityView.layer?.cornerRadius = 10
        self.view.addSubview(sellActivityView)
        
        
    }
    
    func createPaymentView() {
        if paymentView != nil {
            paymentView.removeFromSuperview()
        }
        let ancho = view.frame.width * 0.4
        let alto = view.frame.height * 0.5
        paymentView = PaymentView(frame: CGRect(x: self.view.frame.width - 5, y: 0, width: ancho, height: alto))
        paymentView.destiny = CGPoint(x: self.view.frame.width - ancho, y: 0)
        paymentView.closeWhenBackgroundIsTouch = true
        paymentView.layer?.cornerRadius = 10
        view.addSubview(paymentView)
    }
    
    func createRegisterView() {
        if sellRegisterView != nil {
            sellRegisterView.removeFromSuperview()
        }
        
        sellRegisterView = RegisterListView(frame: CGRect(x: 0, y: 0, width: containerSellRegisters.frame.width, height: containerSellRegisters.frame.height))
        self.containerSellRegisters.addSubview(sellRegisterView)
    }
    
}

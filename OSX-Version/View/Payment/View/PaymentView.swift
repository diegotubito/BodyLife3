//
//  PaymentView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class PaymentView: XibViewBlurBackground, PaymentViewContract {
    
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var myBackground: NSView!
    @IBOutlet weak var amountTextField: NSTextField!
    @IBOutlet weak var titleLineSeparator: NSView!
    @IBOutlet weak var saveButtonView: SaveButtonCustomView!
    var viewmodel : PaymentViewModelContract!
    override func commonInit() {
        super .commonInit()
        viewmodel = PaymentViewModel(withView: self)
        saveButtonView.title = "Guardar"
        titleLineSeparator.wantsLayer = true
        titleLineSeparator.layer?.backgroundColor = Constants.Colors.Gray.gray21.cgColor
        
        buttonSaveObserver()
        createBackgroundGradient()
        
        
    }
    
    func displayInfo() {
        let register = viewmodel.model.selectedSellRegister
        let sellName = register?.description ?? ""
        let amountToPay = register?.price ?? 0.0
        let paid = calcTotalPayments()
        let balance = amountToPay - paid
        infoLabel.stringValue = sellName + ". Total a pagar: \(balance.currencyFormat(decimal: 2))"
        amountTextField.stringValue = String(balance)
        self.enableSaveButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // your code here
            self.amountTextField.becomeFirstResponder()
        }
        
    }
    
    func calcTotalPayments() -> Double {
        var result : Double = 0
        let payments = viewmodel.model.payments
        if payments == nil {return 0}
        for i in payments! {
            result += i.paidAmount
        }
        return result
    }
    
    func createBackgroundGradient() {
        self.layer?.backgroundColor = NSColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5, 1]
        gradient.colors = [NSColor(hex: 0x020707).cgColor,
                           NSColor(hex: 0x403896).withAlphaComponent(0.7).cgColor,
                           NSColor(hex: 0x020707).cgColor]
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.layer?.addSublayer(gradient)
    }
    
    @IBAction func textfieldDIdChanged(_ sender: Any) {
        
    }
    
    func buttonSaveObserver() {
        saveButtonView.onButtonPressed = {
            self.viewmodel.saveNewPayment()
        }
        
    }
    
    func validateAmount() -> Bool {
        let string = amountTextField.stringValue
        
        if Double(string) != nil {
            return true
        }
        return false
    }
    
    func showSuccess() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(.init(name: .needUpdateCustomerList))
            self.hideView()
        }
       
    }
    
    func showError() {
        print("something went wrong")
    }
    
    func getAmountString() -> String {
        return amountTextField.stringValue
    }
    
    func showLoadingButton() {
        DispatchQueue.main.async {
            self.saveButtonView.showLoading()
        }
    }
    
    func hideLoadingButton() {
        DispatchQueue.main.async {
            self.saveButtonView.hideLoading()
        }
    }
    
    func enableSaveButton() {
        DispatchQueue.main.async {
            self.saveButtonView.isEnabled = true
        }
    }
    
    func disableSaveButton() {
        DispatchQueue.main.async {
            self.saveButtonView.isEnabled = false
        }
    }
}

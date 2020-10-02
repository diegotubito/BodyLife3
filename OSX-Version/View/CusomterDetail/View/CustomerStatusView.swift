//
//  CustomerDetailView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa


extension Notification.Name {
    static let notificationUpdateStatus = Notification.Name("notificationUpdateStatus")
}


class CustomerStatusView: XibViewWithAnimation {
    
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var expirationDateLabel: NSTextField!
    @IBOutlet weak var saldoLabel: NSTextField!
    @IBOutlet weak var remainingDayLabel: NSTextField!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var innerBackground: NSView!
    @IBOutlet weak var line: NSView!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    @IBOutlet weak var errorView: NSView!
    var viewModel : CustomerStatusViewModelContract!
    @IBOutlet weak var DayBox: NSBox!
    
    var didPressSellActivityButton : (() -> ())?
    var didPressSellProductButton : (() -> ())?
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
        self.layer?.borderWidth = Constants.Borders.Status.width
        self.layer?.borderColor = Constants.Borders.Status.color
        //self.layer?.backgroundColor = Constants.Colors.Gray.gray10.cgColor
        
        innerBackground.wantsLayer = true
        innerBackground.layer?.backgroundColor = Constants.Colors.Blue.chambray.withAlphaComponent(0.15).cgColor
        innerBackground.layer?.borderColor = NSColor.black.cgColor
        innerBackground.layer?.borderWidth = 2
        
        line.wantsLayer = true
        line.layer?.backgroundColor = Constants.Colors.Gray.gray17.cgColor
        
        errorView.wantsLayer = true
        errorView.layer?.backgroundColor = NSColor.clear.cgColor
        errorView.isHidden = true
        errorView.layer?.zPosition = 100
        
        self.DayBox.wantsLayer = true
        
      
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataFromNotification), name: .notificationUpdateStatus, object: nil)
    }
    
    @objc func updateDataFromNotification(notification: Notification) {
        let userInfo = notification.object as? CustomerStatusModel.StatusInfo
        DispatchQueue.main.async {
            self.showData(statusInfo: userInfo)
        }
    }
    
    func initValues() {
        subtitleLabel.stringValue = ""
        expirationDateLabel.stringValue = ""
        saldoLabel.stringValue = ""
        remainingDayLabel.stringValue = ""
        
    }
    
    func configureBoxDay() {
        self.DayBox.layer?.cornerRadius = self.DayBox.frame.height / 2
        self.DayBox.layer?.borderWidth = 1
        self.DayBox.layer?.borderColor = NSColor.darkGray.cgColor
        
    }
    @IBAction func SellActivityPressed(_ sender: Any) {
        didPressSellActivityButton?()
    }
    @IBAction func SellProductPressed(_ sender: Any) {
        didPressSellProductButton?()
    }
}


extension CustomerStatusView : CustomerStatusViewContract{
    func showData(statusInfo: CustomerStatusModel.StatusInfo?) {
        errorView.isHidden = true
        hideLoading()
        guard let statusInfo = statusInfo else {
            subtitleLabel.stringValue = ""
            expirationDateLabel.stringValue = "?"
            saldoLabel.stringValue = "?"
            remainingDayLabel.stringValue = "?"
            return
        }
        let expiration = statusInfo.expiration.toString(formato: "dd-MM-yyyy")
        let balance = statusInfo.balance.currencyFormat(decimal: 2)
        
        let diff = Date().diasTranscurridos(fecha: statusInfo.expiration)
        subtitleLabel.stringValue = "actividades"
        expirationDateLabel.stringValue = expiration
        remainingDayLabel.stringValue = String(diff!)
        saldoLabel.stringValue = balance
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorView.isHidden = false
            self.errorView.Blur()
        }
    }
    
    func reloadList() {
        
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.initValues()
            self.activityIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimation(nil)
        }
        
    }
    
    
}

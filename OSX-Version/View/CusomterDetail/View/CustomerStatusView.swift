//
//  CustomerDetailView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class CustomerStatusView: XibView {
    
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
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
        
        innerBackground.wantsLayer = true
        innerBackground.layer?.backgroundColor = Constants.Colors.Blue.chambray.withAlphaComponent(0.15).cgColor
        innerBackground.layer?.borderColor = NSColor.black.cgColor
        innerBackground.layer?.borderWidth = 0
        
        line.wantsLayer = true
        line.layer?.backgroundColor = Constants.Colors.Gray.gray17.cgColor
        
        errorView.wantsLayer = true
        errorView.layer?.backgroundColor = NSColor.clear.cgColor
        errorView.isHidden = true
        errorView.layer?.zPosition = 100
        
        self.DayBox.wantsLayer = true
        
      
    }
    
    func start() {
        viewModel.loadData()
    }
    
    func configureBoxDay() {
        self.DayBox.layer?.cornerRadius = self.DayBox.frame.height / 2
        self.DayBox.layer?.borderWidth = 1
        self.DayBox.layer?.borderColor = NSColor.darkGray.cgColor
        
    }
}


extension CustomerStatusView : CustomerStatusViewContract{
    func showSuccess(value: CustomerStatusModel.CustomerStatus?) {
        errorView.isHidden = true
        
        if let data = value {
            titleLabel.stringValue = data.surname + ", " + data.name
            subtitleLabel.stringValue = data.activities
        } else {
            titleLabel.stringValue = "No info"
            subtitleLabel.stringValue = ""
            expirationDateLabel.stringValue = "?"
            saldoLabel.stringValue = "?"
            remainingDayLabel.stringValue = "?"
        }
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
            self.activityIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimation(nil)
        }
        
    }
    
    
}

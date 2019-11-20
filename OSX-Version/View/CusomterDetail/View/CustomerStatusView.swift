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

    var viewModel : CustomerStatusViewModelContract!
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
       
        myView.wantsLayer = true
        myView.layer?.backgroundColor = Constants.Colors.Gray.gray10.cgColor
           
       // self.layer?.backgroundColor = Constants.Colors.Gray.almondFrost.cgColor
        
        
        innerBackground.wantsLayer = true
        innerBackground.layer?.backgroundColor = Constants.Colors.Blue.chambray.withAlphaComponent(0.15).cgColor
        innerBackground.layer?.borderColor = NSColor.black.cgColor
        innerBackground.layer?.borderWidth = 0
        
        line.wantsLayer = true
        line.layer?.backgroundColor = Constants.Colors.Gray.gray17.cgColor
        
           
    }
    
    func start() {
        viewModel.loadData()
    }
}


extension CustomerStatusView : CustomerStatusViewContract{
    func reloadList() {
            
       }
       
       func showLoading() {
    
       }
       
       func hideLoading() {
            
       }
       
       func showData(value: CustomerStatusModel?) {
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
       
}

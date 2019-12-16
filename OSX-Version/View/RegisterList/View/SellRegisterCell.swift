//
//  RegisterCell.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class SellRegisterCell: NSTableCellView {
    @IBOutlet weak var labelCreatedAt: NSTextField!
    @IBOutlet weak var labelDisplayName: NSTextField!
    @IBOutlet weak var labelPrice: NSTextField!
    @IBOutlet weak var labelTotalPayment: NSTextField!
    @IBOutlet weak var labelSaldo: NSTextField!
          
    @IBOutlet weak var activity: NSProgressIndicator!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func displayCell(register: SellRegisterModel) {
        let price = register.price
        let totalPayment : Double = calcTotalPayment(payments: register.payments)
        let saldo = totalPayment - price
        
       
        labelCreatedAt.stringValue = (register.createdAt.toDate()?.toString(formato: "HH:mm"))! + " hs."
        labelDisplayName.stringValue = register.displayName
        labelPrice.stringValue = register.price.formatoMoneda(decimales: 2)
        labelTotalPayment.stringValue = totalPayment.formatoMoneda(decimales: 2)
        labelSaldo.stringValue = saldo.formatoMoneda(decimales: 2)
    }
    
    func calcTotalPayment(payments: [PaymentModel]?) -> Double {
        if payments == nil {return 0}
        var total : Double = 0
        for i in payments! {
            total += i.total
        }
        
        return total
    }
}

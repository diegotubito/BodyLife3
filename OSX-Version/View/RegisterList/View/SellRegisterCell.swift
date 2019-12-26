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
          
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func displayCell(register: SellRegisterModel) {
        let totalPayment = register.totalPayment ?? 0
        let balance = register.balance ?? 0
        
        labelCreatedAt.stringValue = (register.createdAt.toDate()?.toString(formato: "dd-MM-yyy HH:mm"))! + "hs."
        labelDisplayName.stringValue = register.displayName
        labelPrice.stringValue = register.price.formatoMoneda(decimales: 2)
        labelTotalPayment.stringValue = totalPayment.formatoMoneda(decimales: 2)
        labelSaldo.stringValue = balance.formatoMoneda(decimales: 2)
        
        alphaValue = register.isEnabled ? 1.0 : 0.3
        labelSaldo.textColor = balance < 0 ? Constants.Colors.Red.ematita : NSColor.lightGray
    }
   
}

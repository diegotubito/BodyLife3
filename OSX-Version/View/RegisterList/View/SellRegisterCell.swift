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
    @IBOutlet weak var imageTypeOfRegister : NSImageView!
    
    func displayCell(sell: SellModel.NewRegister?) {
        guard let sell = sell else {
            return
        }
        let totalPayment = sell.totalPayment ?? 0
        let balance = sell.balance ?? 0
        let timestamp = sell.timestamp.toDate1970.toString(formato: "dd-MM-yyyy - HH:mm")
        labelCreatedAt.stringValue = timestamp + "HS."
        let labelName = sell.productCategory == ProductCategory.activity.rawValue ? sell.description : sell.description
        labelDisplayName.stringValue = labelName
        labelPrice.stringValue = sell.price?.currencyFormat(decimal: 2) ?? "$0.0"
        labelTotalPayment.stringValue = totalPayment.currencyFormat(decimal: 2)
        labelSaldo.stringValue = balance.currencyFormat(decimal: 2)
        
        alphaValue = sell.isEnabled ? 1.0 : 0.3
        labelSaldo.textColor = balance < 0 ? Constants.Colors.Red.ematita : NSColor.lightGray
        let articleImage = #imageLiteral(resourceName: "beverages-supplier")
        let activityImage = #imageLiteral(resourceName: "carrito")
        imageTypeOfRegister.image = sell.productCategory == ProductCategory.article.rawValue ? articleImage : activityImage
    }
   
}

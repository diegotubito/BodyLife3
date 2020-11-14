//
//  ProductViewItem.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 24/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class ArticleViewItem: GenericCollectionItem<ArticleModel.NewRegister> {
    var colorStockWarning = NSColor.yellow
    var colorStockEmpty = Constants.Colors.Red.ematita
    var colorStockOK = Constants.Colors.Green.fern
    
    @IBOutlet weak var stockBrackground: NSView!
    @IBOutlet weak var stockLabel: NSTextField!
    @IBOutlet weak var productIcon : NSImageView!
    @IBOutlet weak var productName : NSTextField!
    @IBOutlet weak var productPrice : NSTextField!
    
    override var item : ArticleModel.NewRegister! {
        didSet {
            productName.stringValue = item.description
            productPrice.stringValue = item.price.currencyFormat(decimal: 2)
            productIcon.image = #imageLiteral(resourceName: "coca1")
            stockLabel.stringValue = String(item.stock)
            stockBrackground.layer?.backgroundColor = determinateColor().cgColor
        }
    }
    
    private func determinateColor() -> NSColor {
        if item.stock <= 0 {
            return colorStockEmpty
        }
        if item.stock < item.minStock {
            return colorStockWarning
        }
        
        return colorStockOK
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
   
        productName.maximumNumberOfLines = 3
        productName.lineBreakMode = .byWordWrapping
        selectionBorderColor = NSColor.cyan.withAlphaComponent(0.3)
        selectionBackgroundColor = Constants.Colors.Blue.blueWhale
        selectionBorderWidth = 0
        stockBrackground.wantsLayer = true
        stockBrackground.layer?.cornerRadius = 13
        stockBrackground.layer?.backgroundColor = Constants.Colors.Red.ematita.cgColor
        stockLabel.textColor = NSColor.black
        
    }
    
}

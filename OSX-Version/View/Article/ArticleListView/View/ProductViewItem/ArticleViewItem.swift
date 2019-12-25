//
//  ProductViewItem.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 24/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class ArticleViewItem: GenericCollectionItem<ArticleModel> {
    
    @IBOutlet weak var productIcon : NSImageView!
    @IBOutlet weak var productName : NSTextField!
    @IBOutlet weak var productPrice : NSTextField!
    
    override var item : ArticleModel! {
        didSet {
            productName.stringValue = item.name
            productPrice.stringValue = item.price.formatoMoneda(decimales: 2)
            productIcon.image = #imageLiteral(resourceName: "coca2")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        productName.maximumNumberOfLines = 3
        productName.lineBreakMode = .byWordWrapping
        selectionBorderColor = NSColor.cyan.withAlphaComponent(0.3)
        selectionBackgroundColor = NSColor.cyan.withAlphaComponent(0.3)
        selectionBorderWidth = 0
    }
    
}

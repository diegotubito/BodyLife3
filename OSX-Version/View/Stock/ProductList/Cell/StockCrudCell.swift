//
//  StockCrudCell.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class StockCrudCell: GenericCollectionItem<ArticleModel.NewRegister> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
  //      productName.maximumNumberOfLines = 3
  //      productName.lineBreakMode = .byWordWrapping
     
   //     stockBrackground.wantsLayer = true
   //     stockBrackground.layer?.cornerRadius = 13
   //     stockBrackground.layer?.backgroundColor = Constants.Colors.Red.ematita.cgColor
   //     stockLabel.textColor = NSColor.black
       
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
        selectionBorderColor = NSColor.cyan.withAlphaComponent(0.3)
        selectionBackgroundColor = Constants.Colors.Blue.blueWhale
        selectionBorderWidth = 0
    }
 
}


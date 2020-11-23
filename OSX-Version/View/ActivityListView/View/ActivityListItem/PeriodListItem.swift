//
//  ActivityListItem.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class PeriodListItem: GenericCollectionItem<PeriodModel.Populated> {
    @IBOutlet weak var titleLabel: NSTextField!
       
    override var item : PeriodModel.Populated! {
           didSet {
            titleLabel.stringValue = "\(item.days) días - $\(item.price)"
           }
       }
       
       override func viewDidLoad() {
           super .viewDidLoad()
        view.wantsLayer = true
        selectionBorderColor = NSColor.white
        selectionBorderWidth = 2
       
       }
    
}


//
//  ActivityListItem.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivityListItem: GenericCollectionItem<ActivityModel> {
    @IBOutlet weak var titleLabel: NSTextField!
       
       override var item : ActivityModel! {
           didSet {
            titleLabel.stringValue = String(item.days)
           }
       }
       
       override func viewDidLoad() {
           super .viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
       }
    
}


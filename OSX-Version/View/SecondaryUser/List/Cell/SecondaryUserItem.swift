//
//  SecondaryUserItem.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class SecondaryUserItem: GenericCollectionItem<SecondaryUserSessionModel> {
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var role: NSTextField!
    
    override var item: SecondaryUserSessionModel! {
        didSet {
            userName.stringValue = item.userName
            role.stringValue = item.role
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

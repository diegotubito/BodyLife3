//
//  ErrorMessageView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

class ErrorMessageView : XibView {
    var title : String! {
        didSet {
            titleLabel.maximumNumberOfLines = 2
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.stringValue = title
        }
    }
    
    @IBOutlet weak var titleLabel: NSTextField!
    override func commonInit() {
        super .commonInit()
        showView()
    }
    
    func showView() {
        self.wantsLayer = true
        
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.layer?.cornerRadius = 10
        
    }
    
    func hideView() {
        
    }
       
}

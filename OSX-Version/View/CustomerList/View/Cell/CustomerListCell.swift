//
//  CustomerListCell.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class CustomerListCell: NSTableCellView {
    @IBOutlet weak var primerRenglonCell: NSTextField!
    @IBOutlet weak var timeAgoCell: NSTextField!
    @IBOutlet weak var imageIndicator: NSProgressIndicator!
 
    @IBOutlet weak var segundoRenglonCell: NSTextField!
    @IBOutlet weak var tercerRenglonCell: NSTextField!
    @IBOutlet weak var fotoCell: NSButton!
    
    @IBOutlet weak var separateLine : NSView!
    
    override func draw(_ dirtyRect: NSRect) {
        self.wantsLayer = true
        imageIndicator.style = .spinning
        imageIndicator.isDisplayedWhenStopped = false
        fotoCell.wantsLayer = true
        fotoCell.layer?.cornerRadius = (fotoCell.layer?.frame.width)! / 2
        fotoCell.layer?.borderWidth = 2
        separateLine.wantsLayer = true
        separateLine.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor
    }
    
    func showLoading() {
        imageIndicator.startAnimation(nil)
    }
    
    func hideLoading() {
        imageIndicator.stopAnimation(nil)
    }
    
}

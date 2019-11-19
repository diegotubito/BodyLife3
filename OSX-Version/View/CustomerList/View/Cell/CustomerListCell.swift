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
    
    @IBOutlet weak var segundoRenglonCell: NSTextField!
    @IBOutlet weak var tercerRenglonCell: NSTextField!
    @IBOutlet weak var fotoCell: NSButton!
    
    @IBOutlet weak var separateLine : NSView!
    
    override func draw(_ dirtyRect: NSRect) {
        self.wantsLayer = true
        //   self.layer?.backgroundColor = BLDefaults.colors.fondoBarraSuperior.cgColor
        
        fotoCell.wantsLayer = true
        fotoCell.layer?.cornerRadius = (fotoCell.layer?.frame.width)! / 2
        
        separateLine.wantsLayer = true
        separateLine.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor
    }
    
}

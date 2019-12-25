//
//  BaseCustomView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//
import Cocoa

class XibView: NSView {
    var xibName : String?
    var errorNoConnection : NSImageView!

    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
    }
    
    func showErrorConnectionView() {
        errorNoConnection = NSImageView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        errorNoConnection.image = #imageLiteral(resourceName: "NoConnection")
        errorNoConnection.wantsLayer = true
        errorNoConnection.Blur()
        self.addSubview(errorNoConnection)
    
    }
    
    func removeErrorConnectionView() {
        if errorNoConnection != nil {
            errorNoConnection.removeFromSuperview()
        }
    }
    
    internal func commonInit() {
        let xibName = self.xibName ?? String(describing: type(of: self))
        
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(xibName, owner: self, topLevelObjects: &topLevelObjects) {
            if let myView = topLevelObjects?.first(where: { $0 is NSView } ) as? NSView {
                myView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                addSubview(myView)
            }
        }
        
    }
    
    deinit {
        
    }
    
    func removeView() {
        self.removeFromSuperview()
    }
    
}

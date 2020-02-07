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
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
    }
    
    internal func commonInit() {
        addGestureToBackground()
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
    
    func addGestureToBackground() {
        let back = NSView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        back.wantsLayer = true
        self.addSubview(back)
        let click = NSClickGestureRecognizer(target: self, action: #selector(backgroundTouchedHandler))
        back.addGestureRecognizer(click)
    }
    
    @objc func backgroundTouchedHandler() {
        print("touch background")
    }
    
}

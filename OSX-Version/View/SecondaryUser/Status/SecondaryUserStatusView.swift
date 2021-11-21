//
//  SecondaryUserStatusView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    public static let userSecondaryUpdated = Notification.Name(rawValue: "userSecondaryUpdated")
    public static let needSecondaryUserLogin = Notification.Name(rawValue: "needSecondaryUserLogin")
}

class SecondaryUserStatusView: NSView {
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var roleLabel: NSTextField!
    var timer : Timer!
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
        
    }
    
    func commonInit() {
        
        let xibName = String(describing: type(of: self))
        
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(xibName, owner: self, topLevelObjects: &topLevelObjects) {
            if let myView = topLevelObjects?.first(where: { $0 is NSView } ) as? NSView {
                myView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                addSubview(myView)
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(secondaryUserUpdatedHandler), name: .userSecondaryUpdated, object: nil)
        updateValues()
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.lightGray.cgColor
    }

    @IBAction func revokeButtonDidPressed(_ sender: Any) {
        timer.invalidate()
        SecondaryUserSession.Remove()
        NotificationCenter.default.post(name: .needSecondaryUserLogin, object: nil, userInfo: nil)
        updateValues()
    }
   
    @objc func secondaryUserUpdatedHandler() {
        updateValues()
    }
    
    private func updateValues() {
        DispatchQueue.main.async {
            let secondaryUser = SecondaryUserSession.GetUser()
            self.titleLabel.stringValue = (secondaryUser?.userName ?? "Sin usuario")
            self.roleLabel.stringValue = (secondaryUser?.role ?? "-")
            self.setupTimer()
        }
    }
    
    private func setupTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        let secondaryUser = SecondaryUserSession.GetUser()
        let dateDouble = (secondaryUser?.tokenExpiration)
        let date = dateDouble?.toDate1970
        let seconds = Date().segundosTranscurridos(fecha: date ?? Date())
        if seconds ?? 0 <= 0 {
            timer.invalidate()
            SecondaryUserSession.Remove()
            NotificationCenter.default.post(name: .needSecondaryUserLogin, object: nil, userInfo: nil)
        }
        let secondsString = (seconds ?? 0).secondsToHoursMinutesSeconds()
        self.subtitleLabel.stringValue = "\(secondsString)"
    }
}

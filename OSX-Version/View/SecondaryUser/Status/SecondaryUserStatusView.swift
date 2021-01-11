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

class SecondaryUserStatusView: XibView {
    var expirationToken: NSTextField!
    var userNameLabel: NSTextField!
    var timer : Timer!
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
        createLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(secondaryUserUpdatedHandler), name: .userSecondaryUpdated, object: nil)
        updateValues()
    }
    
    func createLabel() {
        let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 0
        self.addSubview(stack)
        
        expirationToken = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 10))
        expirationToken.stringValue = ""
        expirationToken.isEditable = false
        expirationToken.font = NSFont.systemFont(ofSize: 10)
        stack.insertArrangedSubview(expirationToken, at: 0)
        
        userNameLabel = NSTextField(frame: NSRect(x: 0, y: 15, width: self.frame.width, height: 10))
        userNameLabel.stringValue = ""
        userNameLabel.isEditable = false
        stack.insertArrangedSubview(userNameLabel, at: 0)
    }
    
    @objc func secondaryUserUpdatedHandler() {
        updateValues()
        
    }
    
    private func updateValues() {
        DispatchQueue.main.async {
            let secondaryUser = SecondaryUserSession.GetUser()
            self.userNameLabel.stringValue = (secondaryUser?.userName ?? "") + " - " + (secondaryUser?.role.rawValue ?? "")
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
        let secondsString = String(seconds ?? 0)
        self.expirationToken.stringValue = "exp: \(secondsString)"
        
    
    }
}

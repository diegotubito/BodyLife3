//
//  NewUserViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 06/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class NewUserViewController : BaseViewController {
    @IBOutlet weak var displayNameTF: NSTextField!
    @IBOutlet weak var emailTF: NSTextField!
    @IBOutlet weak var passwordTF: NSTextField!
    @IBOutlet weak var repeatPasswordTF: NSTextField!
    override func viewDidLoad() {
        super .viewDidLoad()
        
    }
    @IBAction func cancelDidPressed(_ sender: Any) {
        view.window?.close()
    }
    @IBAction func createNewUserPressed(_ sender: Any) {
        if validate() {
            createNewRegister()
        }
    }
    
    func createNewRegister() {
     
        let body = createRequest()
        
        let url = "\(Config.baseUrl.rawValue)/v1/firebase/user"
        let _services = NetwordManager()
        _services.post(url: url, body: body) { (data, error) in
            guard data != nil else {
                return
            }
        }
    }
    
    func createRequest() -> [String : Any ]{
        let body = ["displayName" : displayNameTF.stringValue,
                    "email" : emailTF.stringValue,
                    "password": passwordTF.stringValue]
        
        return body
    }
    
    func validate() -> Bool {
        if passwordTF.stringValue != repeatPasswordTF.stringValue {
            return false
        }
        if displayNameTF.stringValue.isEmpty {
            return false
        }
        if emailTF.stringValue.isEmpty {
            return false
        }
        return true
    }
}

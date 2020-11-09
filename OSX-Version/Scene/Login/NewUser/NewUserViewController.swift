//
//  NewUserViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 06/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class NewUserViewController : BaseViewController {
    @IBOutlet weak var resultLabel: NSTextField!
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
        self.resultLabel.stringValue = ""
        if validate() {
            createNewRegister { [self] (result) in
                DispatchQueue.main.async {
                    guard let result = result else {
                        self.view.window?.close()
                        return
                    }
                    
                    self.resultLabel.stringValue = result
                }
            }
        }
    }
    
    func createNewRegister(result: @escaping (String?) -> ()) {
        let email = self.emailTF.stringValue
        let body = createRequest()
        
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/firebase/admin/user"
        let _services = NetwordManager()
        _services.post(url: url, body: body) { (data, error) in
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                result("something went wrong")
                return
            }
            
            guard let uid = json["uid"] as? String else {
                let message = json["message"] as? String
                result(message)
                return
            }
            
            self.sendVerificationMail(uid: uid, to: email) { (success) in
                if success {
                    result(nil)
                } else {
                    result("Could not send Verification Mail")
                }
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
    
    func sendVerificationMail(uid: String, to: String, success: @escaping (Bool) -> ()) {
        let link = "\(BLServerManager.baseUrl.rawValue)/v1/firebase/admin/verifyEmail?uid=\(uid)"
        let body = ["to" : to,
                    "text" : "Antes de comenzar a utilizar tu cuenta, debes verificar tu correo haciendo link en el enlace.",
                    "subject": "Verification Account",
                    "link" : link]
        
       
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/sendMail"
        let _services = NetwordManager()
        _services.post(url: url, body: body) { (data, error) in
            guard data != nil else {
                success(false)
                return
            }
            success(true)
        }
    }
}

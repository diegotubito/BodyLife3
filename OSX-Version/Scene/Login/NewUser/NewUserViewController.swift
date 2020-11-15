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
            signup { [self] (result) in
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
    
    func signup(result: @escaping (String?) -> ()) {
        let email = self.emailTF.stringValue
        let body = createRequest()
        
        let endpoint = Endpoint.Create(to: .Firebase(.SighUp(body: body)))
        
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<String>) in
            guard let uid = response.data else {
                result("There's no uid")
                return
            }
            self.sendVerificationMail(uid: uid, to: email) { (success) in
                if success {
                    result(nil)
                } else {
                    result("Could not send Verification Mail")
                }
            }
        } fail: { (error) in
            result(error.rawValue)
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
        
        let endpoint = Endpoint.Create(to: .Firebase(.SendVerificationMail(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            success(true)
        } fail: { (error) in
            success(false)
        }
    }
}

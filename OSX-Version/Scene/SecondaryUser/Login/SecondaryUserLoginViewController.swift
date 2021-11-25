//
//  SecondaryUserLoginViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

protocol SecondaryUserLoginDelegate: AnyObject {
    func didPressExit()
}

class SecondaryUserLoginViewController: NSViewController {
    @IBOutlet weak var usersPopup: NSPopUpButton!
    @IBOutlet weak var loginButtonOutlet: NSButton!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var passwordTF: NSSecureTextField!
    
    weak var delegate: SecondaryUserLoginDelegate?
    
    var users = [SecondaryUserSessionModel]() {
        didSet {
            DispatchQueue.main.async {
                let filteredArray = self.users.filter({$0.isEnabled})
                let titleArray = filteredArray.map({$0.userName})
                self.usersPopup.removeAllItems()
                self.usersPopup.addItems(withTitles: titleArray)
                self.passwordTF.isEnabled = true
                self.passwordTF.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        passwordTF.isEnabled = false
        loadUsers()
    }
    
    private func loadUsers() {
        showLoading()
        let endpoint = Endpoint.Create(to: .SecondaryUser(.Load))
        usersPopup.removeAllItems()
        
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[SecondaryUserSessionModel]>) in
            self.hideLoading()
            guard let users = response.data else {
                DispatchQueue.main.async {
                    self.showError(errorMessage: "no users data")
                    self.view.window?.close()
                }
                return
            }
            self.users = users
            if users.count == 0 {
                //we need to create the first user
                DispatchQueue.main.async {
                    self.createFirstUser()
                }
                self.showError(errorMessage: "Creating admin user for the first time...")
            } else {
                self.showSuccessLoadingUsers()
            }
        } fail: { (error) in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showError(errorMessage: error)
                self.view.window?.close()
            }
        }

    }
    
    private func createFirstUser() {
        let endpoint = Endpoint.Create(to: .SecondaryUser(.CreateFirstUser))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            DispatchQueue.main.async {
                self.loadUsers()
            }
        } fail: { (errorMessage) in
            self.showError(errorMessage: errorMessage)
        }

    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            self.errorLabel.textColor = .white
            self.errorLabel.stringValue = "Cargando..."
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            self.errorLabel.textColor = .red
            self.errorLabel.stringValue = ""
        }
    }
    
    private func showError(errorMessage: String) {
        DispatchQueue.main.async {
            self.errorLabel.stringValue = errorMessage
        }
    }
    
    private func showSuccessLoadingUsers() {
        DispatchQueue.main.async {
            self.errorLabel.stringValue = ""
        }
    }
    
    private func showSuccessLogin() {
        DispatchQueue.main.async {
            self.view.window?.close()
        }
    }
    
    @IBAction func exitButton(_ sender: Any) {
        view.window?.close()
        delegate?.didPressExit()
    }
    
    @IBAction func loginDidPress(_ sender: Any) {
        if users.isEmpty {
            loadUsers()
            return
        }
       
        let index = usersPopup.indexOfSelectedItem
        if index == -1 {return}
        let selectedUser = users[index]
        
        if passwordTF.stringValue.isEmpty {
            showError(errorMessage: "Debe ingresar su clave.")
            return
        }
        
        self.showLoading()
        let endpoint = Endpoint.Create(to: .SecondaryUser(.Login(userName: selectedUser.userName, password: passwordTF.stringValue)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<SecondaryUserSessionModel>) in
            self.hideLoading()
            guard let data = try? JSONEncoder().encode(response.data) else {
                return
            }
            
            SecondaryUserSession.Save(userData: data)
            DispatchQueue.main.async {
                self.view.window?.close()
                NotificationCenter.default.post(name: .userSecondaryUpdated, object: nil, userInfo: nil)
            }
        } fail: { (message) in
            self.hideLoading()
            self.showError(errorMessage: message)
        }
    }
}

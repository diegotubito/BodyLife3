//
//  SecondaryUserLoginViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class SecondaryUserLoginViewController: NSViewController {
    @IBOutlet weak var usersPopup: NSPopUpButton!
    @IBOutlet weak var loginButtonOutlet: NSButton!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var passwordTF: NSTextField!
    
    var users = [SecondaryUserSessionModel]() {
        didSet {
            let titleArray = users.map({$0.userName})
            DispatchQueue.main.async {
                self.usersPopup.removeAllItems()
                self.usersPopup.addItems(withTitles: titleArray)
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        loadUsers()
    }
    
    private func loadUsers() {
        showLoading()
        let endpoint = Endpoint.Create(to: .SecondaryUser(.Load))
        usersPopup.removeAllItems()
        
        BLServerManagerBeta.ApiCall(endpoint: endpoint) { (response: ResponseModel<[SecondaryUserSessionModel]>) in
            self.hideLoading()
            guard let users = response.data else {
                self.showError(errorMessage: "no users data")
                return
            }
            self.users = users
            self.showSuccessLoadingUsers()
        } fail: { (error) in
            self.hideLoading()
            self.showError(errorMessage: error)
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
    @IBAction func loginDidPress(_ sender: Any) {

       
        let index = usersPopup.indexOfSelectedItem
        if index == -1 {return}
        let selectedUser = users[index]
        
        if passwordTF.stringValue.isEmpty {
            showError(errorMessage: "Debe ingresar su clave.")
            return
        }
        
        self.showLoading()
        let endpoint = Endpoint.Create(to: .SecondaryUser(.Login(userName: selectedUser.userName, password: passwordTF.stringValue)))
        BLServerManagerBeta.ApiCall(endpoint: endpoint) { (response: ResponseModel<SecondaryUserSessionModel>) in
            self.hideLoading()
            guard let data = try? JSONEncoder().encode(response.data) else {
                return
            }
            
            SecondaryUserSession.Save(userData: data)
            DispatchQueue.main.async {
                self.view.window?.close()
            }
        } fail: { (message) in
            self.hideLoading()
            self.showError(errorMessage: message)
        }
    }
}

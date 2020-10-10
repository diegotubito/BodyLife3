//
//  AuthManager.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class AuthManager {
   
   /* static let shared = AuthManager()
    static var userData : User?
    
    func ListenAuthChanges() {
        AuthManager.authListener = Auth.auth().addStateDidChangeListener() { auth, user in
            AuthManager.userData = user
            guard let user = user else {
                NotificationCenter.default.post(name: .NotLogin, object: nil)
                return
            }
            
            user.reload { (error) in
                guard error == nil else {
                    print("some error ocurred reloading user firebase auth")
                    return
                }
                
                if user.isEmailVerified {
                    print("email verified")
                     NotificationCenter.default.post(name: .DidLogin, object: nil)
                } else {
                    print("email not verified")
                    user.sendEmailVerification { (error) in
                        print(error?.localizedDescription ?? "unkknown error")
                    }
                    NotificationCenter.default.post(name: .VerifyEmail, object: nil)
                    
                }
            }
            
           
        }
    }
    
    
    public func RegisterNewUser(email: String, password: String, success: @escaping (AuthDataResult?) -> Void, fail: @escaping (Error) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                fail(error!)
                return
            }
            success(user)
        }
     
    }
    
    public func SignOut() {
        do {
            UserSession.Remove()
            try Auth.auth().signOut()
        } catch {
            return
        }
    }
    
    
    public func SignInWithEmail(email: String, password: String, success: @escaping (AuthDataResult?) -> Void, fail: @escaping (Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (usuario, error) in
            guard error == nil else {
                fail(error!)
                return
            }
            
            success(usuario)
        }
    }
    
    public func GetUserByEmail(email: String, success: @escaping ([String]?) -> Void, fail: @escaping (Error?) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { (response, error) in
            guard error == nil else {
                fail(error!)
                return
            }
            guard let response = response else {
                fail(nil)
                return
            }
           
            success(response)
        }
    }
 */
}


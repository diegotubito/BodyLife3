import Cocoa
import Alamofire

class LoginWorker {
    
    func refreshToken() {
        let loginJSON = ["email"      : ""] as [String : Any]
            
            let url = "http://127.0.0.1:3000/auth/v1/development/refreshToken"
            
            Alamofire.request(url, method: .post, parameters: loginJSON, encoding: JSONEncoding.default, headers: nil)
                .responseData { response in
                    switch(response.result) {
                    case .success(_):
                        guard let data = response.value else {
                     //       completion(nil, AuthServiceError.empty_user_data)
                            UserSessionManager.RemoveUserSession()
                            return
                        }
                        
                 
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                            let token = json["token"] as? String
                    
                            var user = UserSessionManager.LoadUserSession()
                            user?.token = token
                            UserSessionManager.updateToken(token!)
                            return
                        } catch {
                            UserSessionManager.RemoveUserSession()
                            
                            if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                     //           completion(nil, AuthServiceError.serializationError)
                                return
                            }
                    
                            let json = try! JSONSerialization.jsonObject(with: response.value!, options: []) as? [String : Any]
                            let code = json?["code"] as? String
                             
                            switch code {
                            case "auth/wrong-password":
                     //           completion(nil, AuthServiceError.auth_wrong_password)
                                break
                            case "auth/too-many-requests":
                      //          completion(nil, AuthServiceError.auth_too_many_wrong_password)
                                break
                            case "auth/invalid-email" :
                      //          completion(nil, AuthServiceError.auth_invalid_email)
                                break
                            case "auth/user-not-found" :
                     //           completion(nil, AuthServiceError.auth_user_not_found)
                                break
        
                            default:
                     //           completion(nil, AuthServiceError.unknown_error)
                                break
                            }
                            
                             return
                        }
                    case .failure(_):
                    //    completion(nil, AuthServiceError.server_error)
                        UserSessionManager.RemoveUserSession()
                        break
                    }
            }
    }
    
    func doLogin(request: Login.Login.Request, completion: @escaping (Login.Login.Response?, AuthServiceError?) -> Void) {
        
        
        let loginJSON = ["email"      : request.userName,
                         "password"   : request.password] as [String : Any]
        
        let url = "http://127.0.0.1:3000/auth/v1/development/login"
        
        Alamofire.request(url, method: .post, parameters: loginJSON, encoding: JSONEncoding.default, headers: nil)
            .responseData { response in
                switch(response.result) {
                case .success(_):
                    guard let data = response.value else {
                        completion(nil, AuthServiceError.empty_user_data)
                        UserSessionManager.RemoveUserSession()
                        return
                    }
                    
             
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                        let token = json["token"] as? String
                        var userJson = json["user"] as? [String : Any]
                        userJson?.updateValue(token!, forKey: "token")
                
                        let dataTransformed = try JSONSerialization.data(withJSONObject: userJson!, options: [])

                        let user = try JSONDecoder().decode(UserSession.self, from: dataTransformed)
                        UserSessionManager.SaveUserSession(userData: dataTransformed)
                        var response = Login.Login.Response()
                        response.user = user
                        completion(response, nil)
                        return
                    } catch {
                        UserSessionManager.RemoveUserSession()
                        
                        if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                            completion(nil, AuthServiceError.serializationError)
                            return
                        }
                
                        let json = try! JSONSerialization.jsonObject(with: response.value!, options: []) as? [String : Any]
                        let code = json?["code"] as? String
                         
                        switch code {
                        case "auth/wrong-password":
                            completion(nil, AuthServiceError.auth_wrong_password)
                            break
                        case "auth/too-many-requests":
                            completion(nil, AuthServiceError.auth_too_many_wrong_password)
                            break
                        case "auth/invalid-email" :
                            completion(nil, AuthServiceError.auth_invalid_email)
                            break
                        case "auth/user-not-found" :
                            completion(nil, AuthServiceError.auth_user_not_found)
                            break
    
                        default:
                            completion(nil, AuthServiceError.unknown_error)
                            break
                        }
                        
                         return
                    }
                case .failure(_):
                    completion(nil, AuthServiceError.server_error)
                    UserSessionManager.RemoveUserSession()
                    break
                }
        }
    }
}

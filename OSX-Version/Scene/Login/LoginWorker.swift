import Cocoa
import Alamofire

class LoginWorker {
    
    /*
    func doLogin(request: Login.Login.Request, completion: @escaping (ServerError?) -> Void) {
        
        
        let loginJSON = ["email"      : request.userName,
                         "password"   : request.password] as [String : Any]
        
        let url = "http://127.0.0.1:3000/auth/v1/development/login"
        
        Alamofire.request(url, method: .post, parameters: loginJSON, encoding: JSONEncoding.default, headers: nil)
            .responseData { response in
                switch(response.result) {
                case .success(_):
                        
                    guard <#condition#> else {
                        <#statements#>
                    }
                        if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                            completion(ServerError.body_serialization_error)
                            return
                        }
                        
                        let json = try! JSONSerialization.jsonObject(with: response.value!, options: []) as? [String : Any]
                        let code = json?["code"] as? String
                        
                        switch code {
                        case "auth/wrong-password":
                            completion(ServerError.auth_wrong_password)
                            break
                        case "auth/too-many-requests":
                            completion(ServerError.auth_too_many_wrong_password)
                            break
                        case "auth/invalid-email" :
                            completion(ServerError.auth_invalid_email)
                            break
                        case "auth/user-not-found" :
                            completion(ServerError.auth_user_not_found)
                            break
                            
                        default:
                            completion(ServerError.unknown_error)
                            break
                        }
                        
                        return
                    
                case .failure(_):
                    completion(ServerError.server_error)
                    break
                }
        }
    }
 */
}

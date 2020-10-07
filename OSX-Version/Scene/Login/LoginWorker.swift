import Cocoa
import Alamofire

class LoginWorker {
    
    
    func doLogin(request: Login.Login.Request, completion: @escaping (Login.Login.Response) -> Void) {
        
        let body = ["email"      : request.userName,
                    "password"   : request.password] as [String : Any]
        let url = Config.Firebase.Login
        let _service = NetwordManager()
        _service.post(url: url, body: body) { (data, error) in
            let response = Login.Login.Response(error: error, data: data)
            completion(response)
        }
    }
 
}

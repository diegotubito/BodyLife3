import Cocoa
import Alamofire
import BLServerManager

class LoginWorker {
    func doLogin(request: Login.Login.Request, completion: @escaping (Login.Login.Response) -> Void) {
        
        let body = ["email"      : request.userName,
                    "password"   : request.password] as [String : Any]
        let url = BLEndpoint.URL.Firebase.Login
        let _service = NetwordManager()
        _service.post(url: url, body: body) { (data, error) in
            var response : Login.Login.Response!
            
            guard error == nil, let data = data else {
                response = Login.Login.Response(error: error, user: nil, data: nil)
                completion(response)
                return
            }
            let user = try? JSONDecoder().decode(FirebaseUserModel.self, from: data)
            response = Login.Login.Response(error: nil, user: user, data: data)
            completion(response)
        }
    }
 
}

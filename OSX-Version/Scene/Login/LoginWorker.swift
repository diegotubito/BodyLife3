import Cocoa
import Alamofire
import BLServerManager

class LoginWorker {
    func doLogin(request: Login.Login.Request, completion: @escaping (Login.Login.Response) -> Void) {
        let body = ["email"      : request.userName,
                    "password"   : request.password] as [String : Any]
        let endpoint = Endpoint.Create(to: .Firebase(.Login(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            var response : Login.Login.Response!
            let user = try? JSONDecoder().decode(FirebaseUserModel.self, from: data!)
            response = Login.Login.Response(error: nil, user: user, data: data)
            completion(response)
        } fail: { (error) in
            var response : Login.Login.Response!
            response = Login.Login.Response(error: ServerError.unknown_error, user: nil, data: nil)
            completion(response)
        }
    }
 
}

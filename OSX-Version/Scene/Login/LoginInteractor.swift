import Cocoa

protocol LoginBusinessLogic {
    func doLogin(request: Login.Login.Request)
}

protocol LoginDataStore {
    //var name: String { get set }
}

class LoginInteractor: LoginBusinessLogic, LoginDataStore {
    var presenter: LoginPresentationLogic?
    var worker: LoginWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doLogin(request: Login.Login.Request) {
       /* let worker = LoginWorker()
        worker.doLogin(request: request) { (error) in
            let response = Login.Login.Response(error: error)
            
            self.presenter?.presentLogin(response: response)
            
        }
        */
        ServerManager.Login(userName: request.userName, password: request.password) { (data,error)  in
            let respose = Login.Login.Response(error: error, data: data)
            self.presenter?.presentLogin(response: respose)
        }
        
        
    }
}

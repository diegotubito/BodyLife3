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
        worker = LoginWorker()
        worker?.doLogin(request: request, completion: { (result, error) in
            let response = Login.Login.Response(user: result?.user, error: error)
            
            self.presenter?.presentLogin(response: response)
        })
      
    }
}

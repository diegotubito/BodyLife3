import Cocoa

protocol NewCustomerBusinessLogic {
    func doSaveNewCustomer(request: PostRequest)
}

protocol NewCustomerDataStore {
    //var name: String { get set }
}

class NewCustomerInteractor: NewCustomerBusinessLogic, NewCustomerDataStore {
    var presenter: NewCustomerPresentationLogic?
    var worker: NewCustomerWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSaveNewCustomer(request: PostRequest) {
        
        let path = "users:\(request.uid):briefData:\(request.childID)"
        ServerManager.Post(path: path, Request: request) { (error) in
            let reponse = NewCustomer.NewCustomer.Response(error: error)
            self.presenter?.presentSomething(response: reponse)
            
        }
    }
}

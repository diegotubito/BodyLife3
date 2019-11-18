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
        var error : ServerError?
        let user = UserSaved.Load()
        let uid = user?.uid
        let path = "users:\(uid!):briefData"
        let semasphore = DispatchSemaphore(value: 0)
        
        let worker = NewCustomerWorker()
        worker.FindCustomer(path: path, key: "dni", value: request.dni) { (jsonArray, err) in
            error = err
            
            if jsonArray?.count ?? 0 > 0 {
                error = ServerError.duplicated
            }
            semasphore.signal()
        }
        
        _ = semasphore.wait(timeout: .distantFuture)
   
        let response = NewCustomer.NewCustomer.Response(error: error)
        if error != nil, error != ServerError.body_serialization_error {
            self.presenter?.presentNewCustomerResult(response: response)
            return
        }
        
        let pathNewCustomer = "users:\(request.uid):briefData:\(request.childID)"
        ServerManager.Post(path: pathNewCustomer, Request: request) { (error) in
            let reponse = NewCustomer.NewCustomer.Response(error: error)
            self.presenter?.presentNewCustomerResult(response: reponse)
            
        }
    }
}

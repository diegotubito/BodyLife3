import Cocoa

protocol NewCustomerBusinessLogic {
    func doSaveNewCustomer(request: NewCustomer.NewCustomer.Request)
}

protocol NewCustomerDataStore {
    //var name: String { get set }
}

class NewCustomerInteractor: NewCustomerBusinessLogic, NewCustomerDataStore {
    var presenter: NewCustomerPresentationLogic?
    var worker: NewCustomerWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSaveNewCustomer(request: NewCustomer.NewCustomer.Request) {
        var error : ServerError?
        let path = "briefData"
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
        
        let pathNewCustomer = "briefData:\(request.childID)"
        ServerManager.Post(path: pathNewCustomer, Request: request) { (error) in
            let reponse = NewCustomer.NewCustomer.Response(error: error)
            self.presenter?.presentNewCustomerResult(response: reponse)
            
        }
        
        let pathImage = "customer"
        let net = NetwordManager()
        if let imageData = request.image.tiffRepresentation {
            net.uploadPhoto(path: pathImage, imageData: imageData, nombre: request.childID, tipo: "jpeg") { (jsonResponse, error) in
                if jsonResponse != nil {
                    print("se subio foto a storage")
                } else {
                    print("no se puedo subir foto")
                }
            }
        }
    }
}

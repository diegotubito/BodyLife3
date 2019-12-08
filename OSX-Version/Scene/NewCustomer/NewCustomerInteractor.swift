import Cocoa

protocol NewCustomerBusinessLogic {
    func doSaveNewCustomer(requestBriefInfo: NewCustomer.NewCustomer.Request, requestFullInfo: NewCustomer.NewCustomer.Request)
}

protocol NewCustomerDataStore {
    //var name: String { get set }
}

class NewCustomerInteractor: NewCustomerBusinessLogic, NewCustomerDataStore {
    var presenter: NewCustomerPresentationLogic?
    var worker: NewCustomerWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSaveNewCustomer(requestBriefInfo: NewCustomer.NewCustomer.Request, requestFullInfo: NewCustomer.NewCustomer.Request) {
        var error : ServerError?
        let path = "\(Paths.fullPersonalData)"
        let semasphore = DispatchSemaphore(value: 0)
        
        let worker = NewCustomerWorker()
        worker.FindCustomer(path: path, key: "dni", value: requestBriefInfo.dni) { (jsonArray, err) in
            error = err
            
            if jsonArray?.count ?? 0 > 0 {
                error = ServerError.duplicated
            }
            semasphore.signal()
        }
        
        _ = semasphore.wait(timeout: .distantFuture)
   
        let response = NewCustomer.NewCustomer.Response(error: error, json: [:])
        if error != nil, error != ServerError.body_serialization_error {
            self.presenter?.presentNewCustomerResult(response: response)
            return
        }
        
        let pathNewCustomerFullInfo = "\(Paths.fullPersonalData):\(requestFullInfo.childID)"
        ServerManager.Post(path: pathNewCustomerFullInfo, Request: requestFullInfo) { (error) in
            
        }
        
        let pathNewCustomerBriefInfo = "\(Paths.customerBrief):\(requestBriefInfo.childID)"
        ServerManager.Post(path: pathNewCustomerBriefInfo, Request: requestBriefInfo) { (error) in
            let json = requestBriefInfo.json
            let reponse = NewCustomer.NewCustomer.Response(error: error, json: json)
            self.presenter?.presentNewCustomerResult(response: reponse)
        }
            
        
        let pathImage = Paths.customerOriginalImage
        let net = NetwordManager()
        if let imageData = requestFullInfo.image.tiffRepresentation {
            net.uploadPhoto(path: pathImage, imageData: imageData, nombre: requestFullInfo.childID, tipo: "jpeg") { (jsonResponse, error) in
                if jsonResponse != nil {
                    print("se subio foto a storage")
                } else {
                    print("no se puedo subir foto")
                }
            }
        }
    }
}

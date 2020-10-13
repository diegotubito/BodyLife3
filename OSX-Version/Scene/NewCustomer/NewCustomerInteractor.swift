import Cocoa
import MapKit

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
        let worker = NewCustomerWorker()
        let semasphore = DispatchSemaphore(value: 0)
        var doExist = false
        worker.FindCustomer(dni: request.dni) { (exist) in
            if exist {
                doExist = true
            }
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if doExist {
            let response = NewCustomer.NewCustomer.Response(error: ServerError.duplicated, customer: nil)
            self.presenter?.presentNewCustomerResult(response: response)
            return
        }
        
        worker.SaveCustomer(customer: request.newUser) { (savedCustomer) in
            guard let savedCustomer = savedCustomer else {
                let response = NewCustomer.NewCustomer.Response(error: nil, customer: nil)
                self.presenter?.presentNewCustomerResult(response: response)
                return
            }
            
            let response = NewCustomer.NewCustomer.Response(error: nil, customer: savedCustomer)
            self.presenter?.presentNewCustomerResult(response: response)
        }
        
        let pathImage = Paths.customerOriginalImage
        let net = NetwordManager()
        if let imageData = request.image.tiffRepresentation {
            net.uploadPhoto(path: pathImage, imageData: imageData, nombre: request.newUser.uid, tipo: "jpeg") { (jsonResponse, error) in
                if jsonResponse != nil {
                    print("se subio foto a storage")
                } else {
                    print("no se puedo subir foto")
                }
            }
        }
    }
}

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
            
            var response = NewCustomer.NewCustomer.Response(error: nil, customer: savedCustomer)
            response.customer?.thumbnailImage = request.thumbnail
            self.presenter?.presentNewCustomerResult(response: response)
        }
        
        worker.saveNewThumbnail(uid: request.newUser.uid, thumbnail: request.thumbnail) { (uploaded) in
            if uploaded {
                print("thumbnail uploaded")
            } else {
                print("thumbnail could not be loaded")
            }
        }
        
        let userId = UserSession?.uid ?? ""
        let pathImage = "\(userId):customer"
        let net = StorageManager()
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

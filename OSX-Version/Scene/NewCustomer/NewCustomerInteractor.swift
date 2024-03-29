import Cocoa
import MapKit

protocol NewCustomerBusinessLogic {
    func doSaveNewCustomer(request: NewCustomer.NewCustomer.Request)
    func doUpdateNewCustomer(request: NewCustomer.NewCustomer.Request, previousDNI: String)
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
            
            self.uploadPictures(_id: savedCustomer._id!, image: request.image)
        }
    }
    
    func uploadPictures(_id: String, image: NSImage?) {
        guard let image = image else {return}
       
        CommonWorker.Image.uploadThumbnail(_id: _id, image: image) { (success) in
            success ? print("thumbnail uploaded") : print("thumbnail fail")
        }
        
        CommonWorker.Image.uploadImage(uid: _id, image: image) { (success) in
            success ? print("storage image uploaded") : print("storage image fail")
        }
    }
    
    func updatePictures(_id: String, image: NSImage?) {
        guard let image = image else {return}
        
        CommonWorker.Image.updateThumbnail(_id: _id, image: image) { (success) in
            if (success != nil) {
                print("thumbnail updated")
            }
        }
        
        CommonWorker.Image.uploadImage(uid: _id, image: image) { (success) in
            success ? print("storage image uploaded") : print("storage image fail")
        }
    }
    
    func doUpdateNewCustomer(request: NewCustomer.NewCustomer.Request, previousDNI: String) {
        let worker = NewCustomerWorker()
        let semasphore = DispatchSemaphore(value: 0)
        var doExist = false
        if request.dni == previousDNI {
            semasphore.signal()
        } else {
            worker.FindCustomer(dni: request.dni) { (exist) in
                if exist {
                    doExist = true
                }
                semasphore.signal()
            }
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if doExist && previousDNI != request.dni {
            let response = NewCustomer.NewCustomer.Response(error: ServerError.duplicated, customer: nil)
            self.presenter?.presentNewCustomerResult(response: response)
            return
        }
        
        worker.UpdateCustomer(customer: request.newUser) { (updatedCustomer) in
            guard let updatedCustomer = updatedCustomer else {
                let response = NewCustomer.NewCustomer.Response(error: nil, customer: nil)
                self.presenter?.presentNewCustomerResult(response: response)
                return
            }
            var response = NewCustomer.NewCustomer.Response(error: nil, customer: updatedCustomer)
            response.customer?.thumbnailImage = request.thumbnail
            self.presenter?.presentUpdateCustomerResult(response: response)
            
            self.updatePictures(_id: updatedCustomer._id!, image: request.image)
        }
    }
}

import Cocoa
import BLServerManager
import MapKit

class NewCustomerWorker {
    func saveNewThumbnail(uid: String, thumbnail: String, completion: @escaping (Bool) -> ()) {
        if thumbnail.isEmpty {
            completion(false)
            return
        }
        
        let body = ["uid": uid,
                    "thumbnailImage": thumbnail,
                    "isEnabled" : true] as [String : Any]
        
        let endpoint = Endpoint.Create(to: .Image(.SaveThumbnail(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            completion(true)
        } fail: { (error) in
            completion(false)
        }

    }
    
    func FindCustomer(dni: String, doExist: @escaping (Bool) -> ()) {
        let endpoint = Endpoint.Create(to: .Customer(.FindByDNI(dni: dni)))
        BLServerManager.ApiCall(endpoint: endpoint) { (respose: ResponseModel<[CustomerModel.Customer]>) in
            respose.count ?? 0 > 0 ? doExist(true) : doExist(false)
        } fail: { (error) in
            doExist(true)
        }
    }
    
    func SaveCustomer(customer: CustomerModel.Full, completion: @escaping (CustomerModel.Customer?) -> ()) {
        let body = encodeNewCustomer(customer)
        let endpoint = Endpoint.Create(to: .Customer(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<CustomerModel.Customer>) in
            completion(response.data)
        } fail: { (error) in
            completion(nil)
        }
    }
    
    private func encodeNewCustomer(_ register: CustomerModel.Full) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
    
    func getFinalAddress(customer: CustomerModel.Full) -> String {
        let street = customer.street
        let locality = customer.locality
        let state = customer.state
        let country = customer.country
        
        let address = street + " " + locality + " " + state + " " + country
        return address
    }
   
}

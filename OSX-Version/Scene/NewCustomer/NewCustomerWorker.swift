import Cocoa
import BLServerManager
import MapKit

class NewCustomerWorker {
    func saveNewThumbnail(uid: String, thumbnail: String, completion: @escaping (Bool) -> ()) {
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/thumbnail"
        let _services = NetwordManager()
        
        if thumbnail.isEmpty {
            completion(false)
            return
        }
        
        let body = ["uid": uid,
                    "thumbnailImage": thumbnail,
                    "isEnabled" : true] as [String : Any]
        
        _services.post(url: url, body: body) { (data, error) in
            if error != nil {
                completion(false)
                return
            }
            guard data != nil else {
                completion(false)
                return
            }
            
            completion(true)
            
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

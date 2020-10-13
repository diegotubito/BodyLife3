import Cocoa

import MapKit

class NewCustomerWorker {
    func FindCustomer(dni: String, doExist: @escaping (Bool) -> ()) {
        let url = "\(Config.baseUrl.rawValue)/v1/customerByDni?dni=\(dni)"
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            guard let data = data else {
                doExist(false)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let count = json?["count"] as? Int, count > 0 {
                doExist(true)
            } else {
                doExist(false)
            }
        }
    }
    
    func SaveCustomer(customer: CustomerModel.Full, completion: @escaping (CustomerModel.Customer?) -> ()) {
        let url = "\(Config.baseUrl.rawValue)/v1/customer"
        let _services = NetwordManager()
        let body = encodeNewCustomer(customer)
        _services.post(url: url, body: body) { (data, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let newUser = try? JSONDecoder().decode(CustomerModel.Customer.self, from: data) else {
                completion(nil)
                return
            }
            completion(newUser)
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

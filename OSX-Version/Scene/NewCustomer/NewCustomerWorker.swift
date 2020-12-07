import Cocoa
import BLServerManager
import MapKit

class NewCustomerWorker {
    func FindCustomer(dni: String, doExist: @escaping (Bool) -> ()) {
        let endpoint = Endpoint.Create(to: .Customer(.FindByDNI(dni: dni)))
        BLServerManager.ApiCall(endpoint: endpoint) { (respose: ResponseModel<[CustomerModel.Customer]>) in
            respose.count ?? 0 > 0 ? doExist(true) : doExist(false)
        } fail: { (error) in
            doExist(true)
        }
    }
    
    func SaveCustomer(customer: CustomerModel.Customer, completion: @escaping (CustomerModel.Customer?) -> ()) {
        let body = encodeNewCustomer(customer)
        let endpoint = Endpoint.Create(to: .Customer(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<CustomerModel.Customer>) in
            completion(response.data)
        } fail: { (error) in
            completion(nil)
        }
    }
    
    func UpdateCustomer(customer: CustomerModel.Customer, completion: @escaping (CustomerModel.Customer?) -> ()) {
        let body = encodeNewCustomer(customer)
        let endpoint = Endpoint.Create(to: .Customer(.Update(uid: customer._id!, body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<CustomerModel.Customer>) in
            completion(response.data)
        } fail: { (error) in
            completion(nil)
        }
    }
    
    private func encodeNewCustomer(_ register: CustomerModel.Customer) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
    
}

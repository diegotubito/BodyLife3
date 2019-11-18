import Cocoa

class NewCustomerWorker {
    func FindCustomer(path: String, key: String, value: String, completion: @escaping ([[String:Any]]?, ServerError?) -> ()) {
        
        ServerManager.FindByKey(path: path, key: key, value: value) { (array, error) in
            completion(array, error)
        }
        
    }
}

import Cocoa

class ExpenseWorker {
    func doLoadTypes(response: @escaping ([String : Any]?, Error?) -> ()) {
        let path = Paths.expenseType
        ServerManager.ReadJSON(path: path) { (json, error) in
            guard error == nil else {
                response(nil, error)
                return
            }
           
            guard let json = json else {
                response(nil, error)
                return
            }
            
            response(json, nil)
            
        }
    }
    
    func doSaveNewExpense(json: [String: Any], response: @escaping (ServerError?) -> ()) {
        let path = Paths.registers
        ServerManager.Update(path: path, json: json) { (data, error) in
            response(error)
        }
    }
}

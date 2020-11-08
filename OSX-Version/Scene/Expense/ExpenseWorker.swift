import Cocoa

class ExpenseWorker {
    func doLoadTypes(response: @escaping ([String : Any]?, Error?) -> ()) {
        let path = Paths.expenseType
       
    }
    
    func doSaveNewExpense(json: [String: Any], response: @escaping (ServerError?) -> ()) {
        let path = Paths.registers
        ServerManager.Update(path: path, json: json) { (data, error) in
            response(error)
        }
    }
}

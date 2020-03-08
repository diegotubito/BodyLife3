import Cocoa

protocol ExpenseBusinessLogic {
    func loadTypes(request: Expense.Types.Request)
    func saveNewExpense(request: Expense.Save.Request)
}

protocol ExpenseDataStore {
    //var name: String { get set }
}

class ExpenseInteractor: ExpenseBusinessLogic, ExpenseDataStore {
   
    var presenter: ExpensePresentationLogic?
    var worker: ExpenseWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func loadTypes(request: Expense.Types.Request) {
        worker = ExpenseWorker()
        worker?.doLoadTypes(response: { (responseJson, error) in
            let regs = self.parseResponse(json: responseJson)
            let response = Expense.Types.Response(types: regs, error: error)
            self.presenter?.presentTypes(response: response)
        })
     }
    
    private func parseResponse(json: [String : Any]?) -> [ExpenseType]? {
        do {
            let array = ServerManager.jsonArray(json: json ?? [:])
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            let registers = try JSONDecoder().decode([ExpenseType].self, from: data)
            return registers
        } catch {
            return nil
        }
    }
    
    func saveNewExpense(request: Expense.Save.Request) {
        let worker = ExpenseWorker()
         
        worker.doSaveNewExpense(json: request.register) { (error) in
            let response = Expense.Save.Response(error: error)
            self.presenter?.presentSaveNewExpense(response: response)
        }
    }
       
}

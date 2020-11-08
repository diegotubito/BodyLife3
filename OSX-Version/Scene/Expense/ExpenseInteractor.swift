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
        
     }
    
    func saveNewExpense(request: Expense.Save.Request) {
        let worker = ExpenseWorker()
         
        worker.doSaveNewExpense(json: request.register) { (error) in
            let response = Expense.Save.Response(error: error)
            self.presenter?.presentSaveNewExpense(response: response)
        }
    }
       
}

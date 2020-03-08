import Cocoa

protocol ExpensePresentationLogic {
    func presentTypes(response: Expense.Types.Response)
    func presentSaveNewExpense(response: Expense.Save.Response)
}

class ExpensePresenter: ExpensePresentationLogic {
    
    
    weak var viewController: ExpenseDisplayLogic?
    
    // MARK: Do something
    
    func presentTypes(response: Expense.Types.Response) {
        let base = getBaseType(response.types)
        let secondary = getSecondaryType(response.types)
        let errorMessage = response.error?.localizedDescription
        let viewModel = Expense.Types.ViewModel(baseTypeTitles: base, secondaryTypeTitles: secondary, errorMessage: errorMessage)
        viewController?.displayTypes(viewModel: viewModel)
    }
    
    private func getBaseType(_ value: [ExpenseType]?) -> [ExpenseType] {
        let result = value?.filter({$0.level == 0})
        return result ?? []
        
    }
    
    private func getSecondaryType(_ value: [ExpenseType]?) -> [ExpenseType] {
        let result = value?.filter({$0.level == 1 && $0.isEnabled})
        return result ?? []
        
    }
    
    func presentSaveNewExpense(response: Expense.Save.Response) {
        if response.error == nil {
            viewController?.displayNewExpenseSavedSuccess()
        } else {
            viewController?.displayNewExpenseSavedError(message: response.error?.localizedDescription)
        }
    }
}

import Cocoa
import BLServerManager

class ExpenseViewController: BaseViewController {
   
    @IBOutlet weak var expenseDate: NSDatePicker!
    @IBOutlet weak var typePopup: NSPopUpButton!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var totalTextField: NSTextField!
    @IBOutlet weak var saveButtonOutlet: NSButton!
    @IBOutlet weak var deleteButtonOutlet: NSButton!
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var toDate: NSDatePicker!
    
    var expenseListView: ExpenseListView!
    
    var expenseCategories: [ExpenseCategoryModel.Register]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createExpenseListView()
        loadExpenseCategories()
        resetValues()
        
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        
    }
    
    private func createExpenseListView() {
        expenseListView = ExpenseListView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 200))
        view.addSubview(expenseListView)
    }
    
    @IBAction func baseTypePopupChanged(_ sender: NSPopUpButton) {
        descriptionTextField.stringValue = ""
        resetValues()
        validate()
    }
    
    @IBAction func amountDidChaned(_ sender: NSTextField) {
        validate()
    }
    @IBAction func expenseDateDidChanged(_ sender: Any) {
        validate()
    }
    
    private func populateTypePopup(registers: [ExpenseCategoryModel.Register]) {
        let baseTitles = registers.filter({$0.isEnabled}).map({$0.description})
        typePopup.removeAllItems()
        typePopup.addItems(withTitles: baseTitles)
    }
    
    private func resetValues() {
        totalTextField.stringValue = "0"
        descriptionTextField.stringValue = ""
        expenseDate.dateValue = Date()
        validate()
    }
        
    func displayNewExpenseSavedError(message: String?) {
        DispatchQueue.main.async {
            self.ShowSheetAlert(title: "Error al guardar nuevo gasto", message: message ?? "unknown error", buttons: [.ok])
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if validateFields() {
            saveNewExpense()
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
    }
    
    private func saveNewExpense() {
        DDBarLoader.showLoading(controller: self, message: "")
        let categoryList = expenseCategories.filter({$0.description == typePopup.titleOfSelectedItem})
        if categoryList.count == 0 { return }
        guard let expenseCategory = categoryList.first,
              let total = Double(totalTextField.stringValue) else { return }
        let createdAt = Date().timeIntervalSince1970
        let body = ["description": descriptionTextField.stringValue,
                    "isEnabled": true,
                    "total":  total,
                    "timestamp": createdAt,
                    "expense_date": expenseDate.dateValue.timeIntervalSince1970,
                    "expense_category": expenseCategory._id] as [String : Any]
        
        
        let endpoint = Endpoint.Create(to: .Expense(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                self.expenseListView.loadExpenses()
                self.resetValues()
            }
        } fail: { (errorMessage) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                self.resetValues()
                self.ShowSheetAlert(title: "Error al guardar nuevo gasto", message: errorMessage, buttons: [.ok])
            }
        }

    }
}

extension ExpenseViewController {
    fileprivate func validate() {
        if validateFields() {
            enableSaveButton()
        } else {
            disableSaveButton()
        }
    }
    
    private func validateFields() -> Bool {
        if expenseDate.dateValue > Date() {
            return false
        }
        
        if typePopup.indexOfSelectedItem == -1 {
            return false
        }
        
        if let value = Double(totalTextField.stringValue), value <= 0 {
            return false
        }
        if let value = Double(totalTextField.stringValue), value > Constants.Max.inputAmountNumber {
            return false
        }
        
        return true
    }
    
    private func enableSaveButton() {
        saveButtonOutlet.isEnabled = true
        saveButtonOutlet.alphaValue = 1
    }
    private func disableSaveButton() {
        saveButtonOutlet.isEnabled = false
        saveButtonOutlet.alphaValue = 0.3
    }
}


extension ExpenseViewController  {
    
    func loadExpenseCategories() {
        let endpoint = Endpoint.Create(to: .ExpenseCategory(.Load))
        
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ExpenseCategoryModel.Register]>) in
            guard let data = response.data else { return }
            self.expenseCategories = response.data
            DispatchQueue.main.async {
                self.populateTypePopup(registers: data)
            }
        } fail: { (errorMessage) in
            DispatchQueue.main.async {
                self.ShowSheetAlert(title: "Error al cargar las categorias de los gastos", message: errorMessage, buttons: [.ok])
            }
        }

        
    }
}

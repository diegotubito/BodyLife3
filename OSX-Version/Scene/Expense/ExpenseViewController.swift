import Cocoa
import BLServerManager

class ExpenseViewController: BaseViewController {
   
    @IBOutlet weak var expenseDate: NSDatePicker!
    @IBOutlet weak var typePopup: NSPopUpButton!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var totalTextField: NSTextField!
    @IBOutlet weak var saveButtonOutlet: NSButton!
    @IBOutlet weak var deleteButtonOutlet: NSButton!
    @IBOutlet weak var disableButtonOutlet: NSButton!
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var toDate: NSDatePicker!
    @IBOutlet weak var footerView: NSView!
    
    var expenseListView: ExpenseListView!
    var expenseCategories: [ExpenseCategoryModel.Register]!
    var selectedExpense: ExpenseModel.Populated? {
        didSet {
            enablePersistentDeleteButton()
            guard let register = selectedExpense,
                  register.isEnabled
            else {
                disableButtonOutlet.isEnabled = false
                return
            }
            enableDeleteButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextField.delegate = self
        totalTextField.delegate = self
        setFilterDates()
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        createExpenseListView()
        loadExpenseCategories()
        resetValues()
    }
    
    private func enablePersistentDeleteButton() {
        #if DEBUG || INTERNAL
            deleteButtonOutlet.isHidden = false
            deleteButtonOutlet.isEnabled = true
        #else
            deleteButtonOutlet.isHidden = true
            deleteButtonOutlet.isEnabled = false
        #endif
    }
    
    private func enableDeleteButton() {
        let currentDate = Date().toString(formato: "dd-MM-yyyy")
        let expenseDate = selectedExpense?.timestamp.toDate1970.toString(formato: "dd-MM-yyyy")
        if currentDate != expenseDate {
            disableButtonOutlet.isEnabled = false
        } else {
            disableButtonOutlet.isEnabled = true
        }
    }
    
    private func createExpenseListView() {
        expenseListView = ExpenseListView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 200))
        setDates()
        expenseListView.expenseDelegate = self
        view.addSubview(expenseListView)
        setExpenseListConstraints()
    }
    
    private func setExpenseListConstraints() {
        expenseListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expenseListView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            expenseListView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            expenseListView.topAnchor.constraint(equalTo: fromDate.bottomAnchor, constant: 16),
            expenseListView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -16)
        ])
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
        if expenseDate.dateValue > Date() {
            expenseDate.dateValue = Date()
        }
        validate()
    }
    
    @IBAction func fromDateDidChanged(_ sender: Any) {
        if fromDate.dateValue > toDate.dateValue {
            fromDate.dateValue = toDate.dateValue
        }
        guard let beginDayDate = setHour(date: fromDate.dateValue, hour: "00:00:00") else { return }
        fromDate.dateValue = beginDayDate
        setDates()
    }
    
    @IBAction func toDateDidChanged(_ sender: Any?) {
        if toDate.dateValue > Date() {
            toDate.dateValue = Date()
        }
        guard let endDayDate = setHour(date: toDate.dateValue, hour: "23:59:59") else { return }
        toDate.dateValue = endDayDate
        setDates()
    }
    
    private func setDates() {
        expenseListView.setDates(fromDate: fromDate.dateValue, toDate: toDate.dateValue)
        selectedExpense = nil
    }
    
    private func setHour(date: Date, hour: String) -> Date? {
        let day = date.day
        let month = date.month
        let year = date.year
        let resultDate = "\(day)-\(month)-\(year) \(hour)".toDate(formato: "dd-MM-yyyy HH:mm:ss")
        return resultDate
    }
    
    private func populateTypePopup(registers: [ExpenseCategoryModel.Register]) {
        let baseTitles = registers.filter({$0.isEnabled}).map({$0.description})
        typePopup.removeAllItems()
        typePopup.addItems(withTitles: baseTitles)
    }
    
    private func resetValues() {
        selectedExpense = nil
        totalTextField.stringValue = "0"
        descriptionTextField.stringValue = ""
        expenseDate.dateValue = Date()
        validate()
    }
    
    private func setFilterDates() {
        let month = Date().month
        let year = Date().year
        toDate.dateValue = Date()
        
        guard let from = "01-\(month)-\(year) 00:00:00".toDate(formato: "dd-MM-yyyy HH:mm:ss"),
              let endDayDate = setHour(date: toDate.dateValue, hour: "23:59:59")
        else { return }
        
        fromDate.dateValue = from
        toDate.dateValue = endDayDate
    }
        
    func displayNewExpenseSavedError(message: String?) {
        DispatchQueue.main.async {
            self.ShowSheetAlert(title: "Error al guardar nuevo gasto", message: message ?? "unknown error", buttons: [.ok])
        }
    }
    @IBAction func descriptionDidChanged(_ sender: Any) {
        validate()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if validateFields() {
            saveNewExpense()
        }
    }
    
    @IBAction func disableDidPressed(_ sender: Any) {
        guard let register = selectedExpense else { return }
        DDBarLoader.showLoading(controller: self, message: "")
        let endpoint = Endpoint.Create(to: .Expense(.Disable(_id: register._id)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                //llamo a este metodo para que actualice el listado, el nombre no es muy descriptivo
                self.toDateDidChanged(nil)
            }
        } fail: { (errorMessage) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                self.ShowSheetAlert(title: "Error al eliminar gasto", message: errorMessage, buttons: [.ok])
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        guard let register = selectedExpense else { return }
        DDBarLoader.showLoading(controller: self, message: "")
        let endpoint = Endpoint.Create(to: .Expense(.Delete(_id: register._id)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                //llamo a este metodo para que actualice el listado, el nombre no es muy descriptivo
                self.toDateDidChanged(nil)
            }
        } fail: { (errorMessage) in
            DispatchQueue.main.async {
                DDBarLoader.hideLoading()
                self.ShowSheetAlert(title: "Error al eliminar gasto", message: errorMessage, buttons: [.ok])
            }
        }
    }
    
    private func saveNewExpense() {
        DDBarLoader.showLoading(controller: self, message: "")
        let categoryList = expenseCategories.filter({$0.description == typePopup.titleOfSelectedItem})
        if categoryList.count == 0 { return }
        guard let expenseCategory = categoryList.first,
              let total = Double(totalTextField.stringValue) else { return }
        let createdAt = Date().timeIntervalSince1970
        let body = ["description": expenseCategory.description + ": " + descriptionTextField.stringValue,
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

extension ExpenseViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        validate()
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
        if descriptionTextField.stringValue.count == 0 {
            return false
        }
        if Double(totalTextField.stringValue) == nil {
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

extension ExpenseViewController: ExpenseListViewDelegate {
    func selectedRow(row: Int) {
        guard row != -1 else {
            selectedExpense = nil
            return
        }
        let json = expenseListView.items[row]
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []),
              let register = try? JSONDecoder().decode(ExpenseModel.Populated.self, from: data)
        else {
            selectedExpense = nil
            return
        }
        selectedExpense = register
    }
}

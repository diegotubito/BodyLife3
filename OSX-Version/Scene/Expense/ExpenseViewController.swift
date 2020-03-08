import Cocoa

protocol ExpenseDisplayLogic: class {
    func displayTypes(viewModel: Expense.Types.ViewModel)
    func displayNewExpenseSavedSuccess()
    func displayNewExpenseSavedError(message: String?)
}

class ExpenseViewController: BaseViewController, ExpenseDisplayLogic {
   
    var interactor: ExpenseBusinessLogic?
    var router: (NSObjectProtocol & ExpenseRoutingLogic & ExpenseDataPassing)?
    
    var baseTypes = [ExpenseType]()
    var secondaryTypes = [ExpenseType]()
    
    @IBOutlet weak var typePopup: NSPopUpButton!
    @IBOutlet weak var secondaryTypePopup: NSPopUpButton!
    @IBOutlet weak var descriptionTextfield: NSTextField!
    @IBOutlet weak var amountTextField: NSTextField!
    @IBOutlet weak var saveOutlet: NSButton!
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ExpenseInteractor()
        let presenter = ExpensePresenter()
        let router = ExpenseRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTypes()

    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        resetAmountTextField()
        validate()
        amountTextField.becomeFirstResponder()
        
    }
    
    // MARK: Do something
    
    @IBAction func baseTypePopupChanged(_ sender: NSPopUpButton) {
        descriptionTextfield.stringValue = ""
        resetAmountTextField()
        updateSecondaryPopupTitles()
        validate()
    }
    
    @IBAction func secondaryTypePopupChanged(_ sender: NSPopUpButton) {
        descriptionTextfield.stringValue = ""
        resetAmountTextField()
        validate()
    }
    
    @IBAction func amountDidChaned(_ sender: NSTextField) {
        validate()
    }
    private func addBaseTypePopup() {
        let baseTitles = baseTypes.filter({$0.level == 0 && $0.isEnabled}).map({$0.name})
        typePopup.removeAllItems()
        typePopup.addItems(withTitles: baseTitles)
    }
    
    private func resetAmountTextField() {
        amountTextField.stringValue = "0,0"
    }
    
    private func updateSecondaryPopupTitles() {
        
        let baseIndex = typePopup.indexOfSelectedItem
        let selectedBaseChildIDType = baseTypes[baseIndex].childID
        let secondaryTitle = secondaryTypes.filter({$0.level == 1 && $0.isEnabled && $0.childIDType == selectedBaseChildIDType}).map({$0.name})
        secondaryTypePopup.removeAllItems()
        secondaryTypePopup.addItems(withTitles: secondaryTitle)
        print(secondaryTypePopup.indexOfSelectedItem)
       
    }
    
    func loadTypes() {
        let request = Expense.Types.Request()
        interactor?.loadTypes(request: request)
    }
    
    func displayTypes(viewModel: Expense.Types.ViewModel) {
        DispatchQueue.main.async {
            if viewModel.errorMessage != nil {
                print("error loading types")
            }
            self.baseTypes = viewModel.baseTypeTitles ?? []
            self.secondaryTypes = viewModel.secondaryTypeTitles ?? []
            
            self.addBaseTypePopup()
            self.updateSecondaryPopupTitles()
        }
         //nameTextField.text = viewModel.name
    }
    
    func displayNewExpenseSavedSuccess() {
        DispatchQueue.main.async {
            DDBarLoader.hideLoading()
            self.view.window?.close()
            print("guardo bien")
            
        }
    }
    
    func displayNewExpenseSavedError(message: String?) {
        DispatchQueue.main.async {
            DDBarLoader.hideLoading()
            self.ShowSheetAlert(title: "Error al guardar nuevo gasto", message: message ?? "unknown error", buttons: [.ok])
            
        }
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        DDBarLoader.showLoading(controller: self, message: "Agregando nuevo gasto")
        
        let today = Date()
        let selectedBaseType = baseTypes[typePopup.indexOfSelectedItem]
        let selectedSecondaryType = secondaryTypes[secondaryTypePopup.indexOfSelectedItem]
        let childIDBaseType = selectedBaseType.childID
        let childIDSecondaryType = selectedSecondaryType.childID
        let childID = ServerManager.createNewChildID()
        let createdAt = today.timeIntervalSinceReferenceDate
        let isEnabled = true
        let operationCategory = OperationCategory.expense
        let displayName = selectedSecondaryType.name
        let displayTypeName = selectedBaseType.name
        let amount = amountTextField.doubleValue
        let queryByY = today.toString(formato: "yyyy")
        let queryByMY = today.toString(formato: "MM-yyyy")
        let queryByDMY = today.toString(formato: "dd-MM-yyyy")
        let optionalDescription = descriptionTextfield.stringValue
        
        let jsonInfo : [String : Any] = ["childIDBaseType" : childIDBaseType,
                                     "childIDSecondaryType" : childIDSecondaryType,
                                     "childID" : childID,
                                     "createdAt" : createdAt,
                                     "isEnabled" : isEnabled,
                                     "displayName" : displayName,
                                     "displayTypeName" : displayTypeName,
                                     "amount" : amount,
                                     "queryByY" : queryByY,
                                     "queryByMY" : queryByMY,
                                     "queryByDMY" : queryByDMY,
                                     "operationCategory" : operationCategory,
                                     "optionalDescription" : optionalDescription]
        
        let finalJson = [childID : jsonInfo]
        
        let request = Expense.Save.Request(register: finalJson)
        interactor?.saveNewExpense(request: request)
    }
}

extension ExpenseViewController {
    fileprivate func validate() {
        if validateFields() {
            enableSabeButton()
        } else {
            disableSabeButton()
        }
    }
    
    private func validateFields() -> Bool {
        var result = true
        
        if typePopup.indexOfSelectedItem == -1 {
            result = false
        }
        if secondaryTypePopup.indexOfSelectedItem == -1 {
            result = false
        }
        if amountTextField.stringValue.count == 0 {
            result = false
        }
        if let value = Double(amountTextField.stringValue), value <= 0 {
            result = false
        }
        if let value = Double(amountTextField.stringValue), value > Constants.Max.inputAmountNumber {
            result = false
        }
        
        return result
    }
    
    private func enableSabeButton() {
        saveOutlet.isEnabled = true
        saveOutlet.alphaValue = 1
    }
    private func disableSabeButton() {
        saveOutlet.isEnabled = false
        saveOutlet.alphaValue = 0.3
    }
}


extension ExpenseViewController : NSTextFieldDelegate {
    
}

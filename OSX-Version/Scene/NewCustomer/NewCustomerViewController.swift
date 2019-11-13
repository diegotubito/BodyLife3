import Cocoa

protocol NewCustomerDisplayLogic: class {
    func displaySaveNewCustomerResult(viewModel: NewCustomer.NewCustomer.ViewModel)
}

class NewCustomerViewController: NSViewController, NewCustomerDisplayLogic {
    var interactor: NewCustomerBusinessLogic?
    var router: (NSObjectProtocol & NewCustomerRoutingLogic & NewCustomerDataPassing)?
    
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
        let interactor = NewCustomerInteractor()
        let presenter = NewCustomerPresenter()
        let router = NewCustomerRouter()
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
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSaveNewCustomer() {
        let user = UserSessionManager.LoadUserSession()
        let uid = (user?.uid)!
        let fechaDouble = Date().timeIntervalSince1970
        let fechaRounded = (fechaDouble * 1000)
        let childID = String(Int(fechaRounded))

        let json = ["childID" : childID,
                    "createdAt" : fechaDouble] as [String : Any]
        
        let request = PostRequest(uid: uid, childID: childID, json: json)
        
        interactor?.doSaveNewCustomer(request: request)
    }
    
    func displaySaveNewCustomerResult(viewModel: NewCustomer.NewCustomer.ViewModel) {
        //nameTextField.text = viewModel.name
        if let errorMessage = viewModel.errorMessage {
            print(errorMessage)
        } else {
            print("success")
            let fecha = Date(timeIntervalSince1970: viewModel.userDecoded!.exp)
            print(fecha.toString(formato: "dd/MM/yyyy HH:mm:ss"))
        }
    }
    @IBAction func saveNewCustomerPressed(_ sender: Any) {
        doSaveNewCustomer()
    }
   
}

import Cocoa

protocol LoginDisplayLogic: class {
    func displayLoginResult(viewModel: Login.Login.ViewModel)
}

class LoginViewController: BaseViewController, LoginDisplayLogic {
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?
    var didLogin : ((Data) -> ())?
    var sameUserName : Bool!
    
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
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
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
        
        setupWindow(width: Constants.ViewControllerSizes.Login.width, height: Constants.ViewControllerSizes.Login.height)

        if sameUserName {
            let user = UserSaved.Load()
            userTextField.stringValue = user?.email ?? ""
            userTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            userTextField.isEnabled = false
        }
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
    
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doLogin() {
        showLoading()
        let userName = userTextField.stringValue
        let password = passwordTextField.stringValue
        let request = Login.Login.Request(userName: userName, password: password)
        interactor?.doLogin(request: request)
    }
    
    func displayLoginResult(viewModel:
        
        Login.Login.ViewModel) {
        //nameTextField.text = viewModel.name
        DispatchQueue.main.async {
            self.hideLoading()
                if viewModel.errorMessage != nil {
                    self.resultLabel.isHidden = false
                    self.resultLabel.stringValue = viewModel.errorMessage!
                    self.enableTextfields()
                } else {
                    self.resultLabel.isHidden = true
                    self.didLogin?(viewModel.data!)
                    self.view.window?.close()
                }
        }
    
    }
    @IBAction func onLoginPressed(_ sender: Any) {
        disableTexfields()
         doLogin()
    }
    
    func enableTextfields() {
        passwordTextField.isHidden = false
        userTextField.isHidden = false
    }
    
    func disableTexfields() {
        passwordTextField.isHidden = true
        userTextField.isHidden = true
        
    }
   
}

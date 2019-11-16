import Cocoa

protocol HomeDisplayLogic: class {
    func displaySomething(viewModel: Home.Something.ViewModel)
}

class HomeViewController: BaseViewController, HomeDisplayLogic, NSWindowDelegate {
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
    @IBOutlet weak var backgroundImage: NSImageView!
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
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWindow(width: Constants.ViewControllerSizes.Home.width, height: Constants.ViewControllerSizes.Home.height)
        
       
      
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        
           // setupListadoSocios()
        // setupDetalleSocioSeleccionado()
    }
    // MARK: Do something
     
    func displaySomething(viewModel: Home.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
    @IBAction func closeSessionPressed(_ sender: Any) {
        UserSaved.Remove()
        
        CheckLogin()
    }
    @IBAction func newCustomerPressed(_ sender: Any) {
        router?.routeToNewCustomer()
    }
    
}


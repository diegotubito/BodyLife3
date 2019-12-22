import Cocoa

protocol HomeDisplayLogic: class {
    func displaySomething(viewModel: Home.Something.ViewModel)
}

class HomeViewController: BaseViewController, HomeDisplayLogic, NSWindowDelegate {
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
    @IBOutlet weak var containerUpperBar: NSView!
    @IBOutlet weak var containerBottomBar: NSView!
    @IBOutlet weak var containerCustomerList: NSView!
    @IBOutlet weak var containerSellRegisters: NSView!
    @IBOutlet weak var containerStatus: NSView!
    @IBOutlet weak var backgroundImage: NSImageView!
    var customerStatusView: CustomerStatusView!
    var customerListView : CustomerListView!
    var sellActivityView : SellActivityCustomView!
    var sellRegisterView : RegisterListView!
    var paymentView : PaymentView!
    var timerForDelayCustomerSelection : Timer!
    var selectedCustomer : CustomerModel?
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
        print("window: viewDidLoad")
           
        setupWindow(width: Constants.ViewControllerSizes.Home.width, height: Constants.ViewControllerSizes.Home.height)
          
        
        NotificationCenter.default.addObserver(self, selector: #selector(didConnected), name: .notificationConnected, object: nil)
        
        
        self.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear() {
   
        super.viewWillAppear()
        self.view.window?.delegate = self
 
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        print("Window: DidAppear")
        
        self.createCustomViews()
        self.view.window?.styleMask.remove(.resizable)
       createBackgroundGradient()
      }
    
    func windowDidResize(_ notification: Notification) {
        print("window: didResize")
    }
    
    @objc func didConnected() {
        DispatchQueue.main.async {
            self.customerListView.startLoading()
            self.addObservers()
        }
    }
    
    @objc func loadStatus() {
        if selectedCustomer == nil {return}
        self.didSelectCustomer(customerSelected: selectedCustomer!)
        
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
    
    func createBackgroundGradient() {
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.33, 0.66, 1.0]
        gradient.colors = [NSColor.init(white: 0.15, alpha: 1).cgColor,
                           NSColor.init(white: 0.1, alpha: 1).cgColor,
                           NSColor.init(white: 0.07, alpha: 1).cgColor]
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.view.layer?.addSublayer(gradient)
    }
    
 }

struct CustomerModel2: Decodable {
    var childID : String
    var createdAt : Double
}

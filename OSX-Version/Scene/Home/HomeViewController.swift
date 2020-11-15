import Cocoa
import BLServerManager

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
    var customerStatusView: CustomerStatusView!
    var customerListView : CustomerListView!
    var sellActivityView : ActivitySaleView!
    var sellRegisterView : RegisterListView!
    var paymentView : PaymentView!
    var sellProductView : ArticleSellView!
    var timerForDelayCustomerSelection : Timer!
    var selectedCustomer : CustomerModel.Customer?
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
          
        
        NotificationCenter.default.addObserver(self, selector: #selector(StartLoading), name: .CommunicationStablished, object: nil)
        
        
        self.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
        
    }
    
   
    @IBAction func addGenericButtob(_ sender: Any) {
        addGeneric()
    }
    func addGeneric() {
           //text tableview generic
               let generic = GenericTableView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        generic.wantsLayer = true
        generic.layer?.backgroundColor = NSColor.white.cgColor
               view.addSubview(generic)

        
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        self.view.window?.delegate = self
        
       
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        self.view.window?.styleMask.remove(.resizable)
       createBackgroundGradient()
      }
    
    func windowDidResize(_ notification: Notification) {
    }
    
    @objc func StartLoading() {
       
        DispatchQueue.main.async {
            self.createCustomViews()
            self.addObservers()
            
            self.customerListView.startLoading()
            NotificationCenter.default.post(.init(name: .needUpdateArticleList))
            NotificationCenter.default.post(.init(name: .needUpdateProductService))
            self.view.window?.title = UserSaved.GetUser()?.displayName ?? "Sin Nombre"
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
    
    @IBAction func importData(_ sender: Any) {
      //  ImportDatabase.Discount.MigrateToMongoDB()
      //  ImportDatabase.Activity.MigrateToMongoDB()
      //  ImportDatabase.Period.MigrateToMongoDB()
      //  ImportDatabase.Article.MigrateToMongoDB()
        
      //  ImportDatabase.Customer.MigrateToMongoDB()
        
        //this also create thumbnail and move old bucket pictures to new
        ImportDatabase.Thumbnail.MigrateToMongoDB()
        
        //this only move old bucket photos to new bucket
//        ImportDatabase.Storage.MovePhotosToAnotherFolder()
        
//        ImportDatabase.Carnet.MigrateToMongoDB()
//        ImportDatabase.VentaArticulo.MigrateToMongoDB()
//        ImportDatabase.PagoCarnet.MigrateToMongoDB()
//        ImportDatabase.PagoArticulo.MigrateToMongoDB()
    }
    
    @IBAction func closeSessionPressed(_ sender: Any) {
        let endpoint = Endpoint.Create(to: .DisconnectMongoDB)
        BLServerManager.ApiCall(endpoint: endpoint) { (success: Bool) in
            print("MongoDB database disconnected.")
            UserSaved.Remove()
            self.GoToLogin()
        } fail: { (error) in
            print("Could not disconnect MongoDB database.")
        }
    }
    @IBAction func newExpensePressed(_ sender: Any) {
        router?.routeToNewExpense()
    }
    @IBAction func newCustomerPressed(_ sender: Any) {
        router?.routeToNewCustomer()
    }
    
    @IBAction func moneyFlow(_ sender: Any) {
        
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

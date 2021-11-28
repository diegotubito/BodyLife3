import Cocoa
import BLServerManager

protocol HomeDisplayLogic: AnyObject {
    func displaySomething(viewModel: Home.Something.ViewModel)
}

class HomeViewController: BaseViewController, HomeDisplayLogic, NSWindowDelegate, CommonRouterProtocol {
   
    @IBOutlet weak var crudOutlet: NSButton!
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
    @IBOutlet weak var secondaryUserStatusViewContainer: NSView!
    @IBOutlet weak var StockUpdate: NSButton!
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
    var stockTableView : StockTableView!
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
        setupWindow(proportionalWidth: Constants.ViewControllerSizes.Home.width, proportionalHeight: Constants.ViewControllerSizes.Home.height)
        NotificationCenter.default.addObserver(self, selector: #selector(StartLoading), name: .CommunicationStablished, object: nil)
        self.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.loadStatus), userInfo: nil, repeats: false)
        NotificationCenter.default.addObserver(self, selector: #selector(GoToSecondaryLogin), name: .needSecondaryUserLogin, object: nil)
    }
    
   
    
    @objc func GoToSecondaryLogin() {
        routeToSecondaryLogin(vc: self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.delegate = self
        containerBottomBar.isHidden = true
        StockUpdate.isHidden = true
        crudOutlet.isHidden = true
        #if DEBUG || INTERNAL
        containerBottomBar.isHidden = false
        StockUpdate.isHidden = false
        crudOutlet.isHidden = false
        #endif
        showLoading()
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        self.view.window?.styleMask.remove(.resizable)
    }
  
    @objc func StartLoading() {
       print("Start Loading")
        DispatchQueue.main.async {
            self.hideLoading()
            self.createBackgroundGradient()
            self.createCustomViews()
            self.addObservers()
            
            self.customerListView.startLoading()
            NotificationCenter.default.post(.init(name: .needUpdateArticleList))
            NotificationCenter.default.post(.init(name: .needUpdateProductService))
            let user = MainUserSession.GetUser()
            let userTitle = (user?.displayName ?? "Sin Nombre") + " (\(user?.email ?? ""))"
            self.view.window?.title = userTitle
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
    @IBAction func removeCustomer(_ sender: Any) {
        guard let customer = customerListView.viewModel.model.selectedCustomer else {
            return
        }
        let endpoint = Endpoint.Create(to: .Customer(.Delete(uid: customer._id!)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            print("socio borrado")
            self.customerListView.viewModel.loadCustomers(offset: 0)
        } fail: { (error) in
            print("no se pudo borrar el socio")
        }
        

    }
    
    @IBAction func createSecondaryUser(_ sender: Any) {
        
    }
    
    @IBAction func importData(_ sender: Any) {
        let primaryAccount = CashAccountModel(id: "111111111111",
                                          description: "Caja Chica".localized,
                                          amount: 0,
                                          isEnabled: true,
                                          timestamp: Date().timeIntervalSince1970,
                                          userRole: "TRAINNER_ROLE",
                                          isPermanent: true,
                                          needNotification: false)
        let secondaryAccount = CashAccountModel(id: "222222222222",
                                          description: "Cuenta Externa".localized,
                                          amount: 0,
                                          isEnabled: true,
                                          timestamp: Date().timeIntervalSince1970,
                                          userRole: "ADMIN_ROLE",
                                          isPermanent: true,
                                          needNotification: false)
        CommonWorker.CashAccount.createCashAccount(account: primaryAccount)
        CommonWorker.CashAccount.createCashAccount(account: secondaryAccount)
        
    //    CommonWorker.CashAccount.transaction(accountId: "111111111111", amount: -100.50)
   //    ImportDatabase.Discount.MigrateToMongoDB()
   //     ImportDatabase.Activity.MigrateToMongoDB()
   //     ImportDatabase.Period.MigrateToMongoDB()
   //     ImportDatabase.Article.MigrateToMongoDB()
        
   //     ImportDatabase.Customer.MigrateToMongoDB()
        
        //this also create thumbnail and move old bucket pictures to new
   //     ImportDatabase.Thumbnail.MigrateToMongoDB()
        
        //this only move old bucket photos to new bucket
//        ImportDatabase.Storage.MovePhotosToAnotherFolder()
        
     //   ImportDatabase.Carnet.MigrateToMongoDB()
     //   ImportDatabase.VentaArticulo.MigrateToMongoDB()
     //   ImportDatabase.PagoCarnet.MigrateToMongoDB()
     //   ImportDatabase.PagoArticulo.MigrateToMongoDB()
    }
    
    @IBAction func closeSessionPressed(_ sender: Any) {
        let endpoint = Endpoint.Create(to: .DisconnectMongoDB)
        MainUserSession.Remove()
        self.GoToLogin()
        BLServerManager.ApiCall(endpoint: endpoint) { (success: Bool) in
            print("MongoDB database disconnected.")
           
            
        } fail: { (error) in
            print("Could not disconnect MongoDB database.")
        }
    }
    @IBAction func newExpensePressed(_ sender: Any) {
        router?.routeToNewExpense()
    }
    @IBAction func Crud(_ sender: Any) {
        router?.routeToSettings()
    }
    @IBAction func stockPressed(_ sender: Any) {
        stockTableView.showView()
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

extension HomeViewController: SecondaryUserLoginDelegate {
    func didPressExit() {
        view.window?.close()
    }
}

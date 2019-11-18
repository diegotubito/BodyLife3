import Cocoa
import AlamofireImage

protocol NewCustomerDisplayLogic: class {
    func displaySaveNewCustomerResult(viewModel: NewCustomer.NewCustomer.ViewModel)
}

class NewCustomerViewController: BaseViewController, NewCustomerDisplayLogic {
    @IBOutlet weak var guardarButtonOutlet: NSButton!
    @IBOutlet weak var CustomerIconImageView: NSImageView!
    @IBOutlet weak var dniTF: NSTextField!
    @IBOutlet weak var dniLabel: NSTextField!
    @IBOutlet weak var apellidoTF: NSTextField!
    @IBOutlet weak var apellidoLabel: NSTextField!
    @IBOutlet weak var nombreTF: NSTextField!
    @IBOutlet weak var nombreLabel: NSTextField!
    @IBOutlet weak var direccionTF: NSTextField!
    @IBOutlet weak var direccionLabel: NSTextField!
    @IBOutlet weak var telefonoPrincipalTF: NSTextField!
    @IBOutlet weak var telefonoPrincipalLabel: NSTextField!
    @IBOutlet weak var telefonoSecundarioTF: NSTextField!
    @IBOutlet weak var telefonoSecundarioLabel: NSTextField!
    @IBOutlet weak var fechaNacimiento: NSDatePicker!
    @IBOutlet weak var generoPUB: NSPopUpButton!
    @IBOutlet weak var obraSocialTF: NSTextField!
    @IBOutlet weak var obraSocialLabel: NSTextField!
    @IBOutlet weak var emailTF: NSTextField!
    @IBOutlet weak var emailLabel: NSTextField!
    var interactor: NewCustomerBusinessLogic?
    var router: (NSObjectProtocol & NewCustomerRoutingLogic & NewCustomerDataPassing)?
    
    var thumbImageBase64 : String = ""
    var image : NSImage = NSImage()
    
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
        
        CustomerIconImageView.wantsLayer = true
        CustomerIconImageView.layer?.borderColor = NSColor.black.cgColor
        CustomerIconImageView.layer?.cornerRadius = 20
        CustomerIconImageView.layer?.borderWidth = 2
        
    
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSaveNewCustomer() {
        let request = createRequest()
        interactor?.doSaveNewCustomer(request: request)
    }
    
    func createRequest() -> PostRequest {
        let user = UserSaved.Load()
        let uid = (user?.uid)!
        let fechaDouble = Date().timeIntervalSince1970
        let fechaRounded = (fechaDouble * 1000)
        let childID = String(Int(fechaRounded))
        
        let fullJSON = ["childID" : childID,
                        "createdAt" : fechaDouble,
                        "dni": dniTF.stringValue,
                        "surname" : apellidoTF.stringValue,
                        "name": nombreTF.stringValue,
                        "address":direccionTF.stringValue,
                        "phone":telefonoPrincipalTF.stringValue,
                        "secondaryPhone":telefonoSecundarioTF.stringValue,
                        "socialSecurity":obraSocialTF.stringValue,
                        "email":emailTF.stringValue,
                        "thumbnailImage" : thumbImageBase64] as [String : Any]
        
        let request = PostRequest(uid: uid, childID: childID, dni: dniTF.stringValue, json: fullJSON)
         
        
        return request
        
    }
    
    func displaySaveNewCustomerResult(viewModel: NewCustomer.NewCustomer.ViewModel) {
        //nameTextField.text = viewModel.name
        if let error = viewModel.errorMessage {
            if error == ServerError.invalidToken {
                self.GoToLogin(sameUserName: true)
            } else if error == ServerError.duplicated {
                ShowSheetAlert(title: "El DNI ya existe", message: "Es posible que el socio ya haya sido ingresado anteriormente.", buttons: [.ok])
                
            } else {
                let message = ErrorHandler.Server(error: error)
                ShowSheetAlert(title: "Error", message: message, buttons: [.ok])
            }
        } else {
          
            DispatchQueue.main.async {
                 
                self.notificationMessage(messageID: self.dniTF.stringValue,
                                         title: "Nuevo Socio",
                                         subtitle: self.apellidoTF.stringValue + ", " + self.nombreTF.stringValue,
                                         informativeText: "Sigamos sumando.")
                 self.view.window?.close()
                
            }
        }
    }
    @IBAction func saveNewCustomerPressed(_ sender: Any) {
        self.doSaveNewCustomer()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        view.window?.close()
    }
    @IBAction func camaraPressed(_ sender: Any) {
        router?.routeToCameraViewController()
    }
}


extension NewCustomerViewController: CameraViewControllerDelegate {
    func imagenCapturada(image: NSImage) {
        print("original image: \(String(describing: image.sizeInBytes))")
    
        let mediumImage = image.crop(size: NSSize(width: image.height*0.5, height: image.height*0.5))
         print("thumbnail image: \(String(describing: mediumImage?.sizeInBytes))")
      
        
        let thumb = image.crop(size: NSSize(width: 30, height: 30))
        print("thumbnail image: \(String(describing: thumb?.sizeInBytes))")
        
        thumbImageBase64 = (thumb?.convertToBase64)!
        self.image = mediumImage!
        
        DispatchQueue.main.async {
            self.CustomerIconImageView.image = mediumImage
        }
        
    }
}

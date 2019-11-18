import Cocoa

@objc protocol NewCustomerRoutingLogic {
    func routeToCameraViewController()
}

protocol NewCustomerDataPassing {
    var dataStore: NewCustomerDataStore? { get }
}

class NewCustomerRouter: NSObject, NewCustomerRoutingLogic, NewCustomerDataPassing {
    weak var viewController: NewCustomerViewController?
    var dataStore: NewCustomerDataStore?
    
    func routeToCameraViewController()
    {
        let storyboard = NSStoryboard(name: "NewCustomerStoryboard", bundle: nil)
         
        let destinationVC = storyboard.instantiateController(withIdentifier: "CameraViewController") as! CameraViewController
        destinationVC.delegate = viewController
        navigateToSomewhere(source: viewController!, destination: destinationVC)
    }
    
    // MARK: Navigation
    
    func navigateToSomewhere(source: NewCustomerViewController, destination: NSViewController)
    {
        source.presentAsSheet(destination)
    }
}

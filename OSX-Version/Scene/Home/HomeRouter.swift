import Cocoa

@objc protocol HomeRoutingLogic {
    func routeToNewCustomer()
}

protocol HomeDataPassing {
    var dataStore: HomeDataStore? { get }
}

class HomeRouter: NSObject, HomeRoutingLogic, HomeDataPassing {
    weak var viewController: HomeViewController?
    var dataStore: HomeDataStore?
    
    // MARK: Routing
    
    func routeToNewCustomer()
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
         
        let destinationVC = storyboard.instantiateController(withIdentifier: "NewCustomerViewController") as! NewCustomerViewController
        
        navigateToSomewhere(source: viewController!, destination: destinationVC)
    }
    
    // MARK: Navigation
    
    func navigateToSomewhere(source: HomeViewController, destination: NSViewController)
    {
        source.presentAsSheet(destination)
    }
    
    //  MARK: Passing data
    
    func passDataToSomewhere(source: HomeDataStore, destination: inout LoginDataStore)
    {
        
    }
}

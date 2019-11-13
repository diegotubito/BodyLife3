import Cocoa

@objc protocol NewCustomerRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol NewCustomerDataPassing {
    var dataStore: NewCustomerDataStore? { get }
}

class NewCustomerRouter: NSObject, NewCustomerRoutingLogic, NewCustomerDataPassing {
    weak var viewController: NewCustomerViewController?
    var dataStore: NewCustomerDataStore?
    
    // MARK: Routing
    
//    func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}
    
    // MARK: Navigation
    
    //func navigateToSomewhere(source: NewCustomerViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    //func passDataToSomewhere(source: NewCustomerDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}

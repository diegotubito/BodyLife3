import Cocoa

@objc protocol ExpenseRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol ExpenseDataPassing {
    var dataStore: ExpenseDataStore? { get }
}

class ExpenseRouter: NSObject, ExpenseRoutingLogic, ExpenseDataPassing {
    weak var viewController: ExpenseViewController?
    var dataStore: ExpenseDataStore?
    
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
    
    //func navigateToSomewhere(source: ExpenseViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    //func passDataToSomewhere(source: ExpenseDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}

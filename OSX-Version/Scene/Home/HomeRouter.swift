import Cocoa

@objc protocol HomeRoutingLogic {
    func routeToNewCustomer()
    func routeToNewExpense()
    func routeToMoneyFlow()
    func routeToSettings()
}

protocol HomeDataPassing {
    var dataStore: HomeDataStore? { get }
}

class HomeRouter: NSObject, HomeRoutingLogic, HomeDataPassing {
    
    weak var viewController: HomeViewController?
    var dataStore: HomeDataStore?
    
    // MARK: Routing
    
    func routeToMoneyFlow() {
        let storyboard = NSStoryboard(name: "MoneyFlow", bundle: nil)
    }
    
    func routeToNewExpense() {
        let storyboard = NSStoryboard(name: "Expense", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "ExpenseViewController") as! ExpenseViewController
        navigateToSomewhere(source: viewController!, destination: vc)
        
    }
    
    func routeToNewCustomer()
    {
        let storyboard = NSStoryboard(name: "NewCustomerStoryboard", bundle: nil)
        
        let destinationVC = storyboard.instantiateController(withIdentifier: "NewCustomerViewController") as! NewCustomerViewController
        
        navigateToSomewhere(source: viewController!, destination: destinationVC)
    }
    
    func routeToSettings()
    {
        let destinationVC = SettingsViewController()
        viewController?.presentAsModalWindow(destinationVC)
    }
    
    func routeToMovements()
    {
        let storyboard = NSStoryboard(name: "Movement", bundle: nil)
        
        let destinationVC = storyboard.instantiateController(withIdentifier: "NewCustomerViewController") as! NSViewController
        
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

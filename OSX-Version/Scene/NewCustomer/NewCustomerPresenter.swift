import Cocoa

protocol NewCustomerPresentationLogic {
    func presentSomething(response: NewCustomer.NewCustomer.Response)
}

class NewCustomerPresenter: NewCustomerPresentationLogic {
    weak var viewController: NewCustomerDisplayLogic?
    
    // MARK: Do something
    
    func presentSomething(response: NewCustomer.NewCustomer.Response) {
        var viewModel = NewCustomer.NewCustomer.ViewModel()
        if let error = response.error {
            viewModel.errorMessage = ErrorHandler.ServerErrorHandler(error: error)
        }
        
        viewModel.userDecoded = response.userDecoded
          
        
                
        viewController?.displaySaveNewCustomerResult(viewModel: viewModel)
        
    }
}

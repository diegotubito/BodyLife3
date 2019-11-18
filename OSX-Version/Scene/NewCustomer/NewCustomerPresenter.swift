import Cocoa

protocol NewCustomerPresentationLogic {
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response)
}

class NewCustomerPresenter: NewCustomerPresentationLogic {
   
    
    weak var viewController: NewCustomerDisplayLogic?
    
    // MARK: Do something
    
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response) {
        var viewModel = NewCustomer.NewCustomer.ViewModel()
        if let error = response.error {
            viewModel.errorMessage = error
        }
        viewController?.displaySaveNewCustomerResult(viewModel: viewModel)
        
    }
   
}

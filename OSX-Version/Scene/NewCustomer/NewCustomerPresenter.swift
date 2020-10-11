import Cocoa

protocol NewCustomerPresentationLogic {
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response)
}

class NewCustomerPresenter: NewCustomerPresentationLogic {
    
    weak var viewController: NewCustomerDisplayLogic?
    
    // MARK: Do something
    
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response) {
        
        guard let customer = response.customer else {
            if response.error == ServerError.duplicated {
                viewController?.customerAlreadyExist()
            } else {
                viewController?.customerCouldNotBeSaved(message: response.error?.localizedDescription ?? "Algo salio mal")
            }
            return
        }
        let viewModel = NewCustomer.NewCustomer.ViewModel(customer: customer)
        viewController?.customerSaved(viewModel: viewModel)
    }
}

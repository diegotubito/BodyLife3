import Cocoa

protocol NewCustomerPresentationLogic {
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response)
}

class NewCustomerPresenter: NewCustomerPresentationLogic {
   
    
    weak var viewController: NewCustomerDisplayLogic?
    
    // MARK: Do something
    
    func presentNewCustomerResult(response: NewCustomer.NewCustomer.Response) {
        let customer = parseCustomer(json: response.json)
        var viewModel = NewCustomer.NewCustomer.ViewModel(customer: customer)
        if let error = response.error {
            viewModel.errorMessage = error
        }
        viewController?.displaySaveNewCustomerResult(viewModel: viewModel)
        
    }
    
    func parseCustomer(json: [String : Any]) -> CustomerModel? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let customer = try JSONDecoder().decode(CustomerModel.self, from: data)
            return customer
        } catch {
            return nil
        }
    }
   
}

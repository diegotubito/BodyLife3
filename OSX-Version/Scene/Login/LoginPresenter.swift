import Cocoa

protocol LoginPresentationLogic {
    func presentLogin(response: Login.Login.Response)
}

class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    // MARK: Do something
    
    func presentLogin(response: Login.Login.Response) {
        var viewModel = Login.Login.ViewModel()
        if let error = response.error {
            viewModel.errorMessage = ErrorHandler.Server(error: error)
        }
        viewModel.user = response.user
        viewModel.data = response.data
        viewController?.displayLoginResult(viewModel: viewModel)
    }
    
    
}

import Cocoa

protocol LoginPresentationLogic {
    func presentLogin(response: Login.Login.Response)
}

class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    // MARK: Do something
    
    func presentLogin(response: Login.Login.Response) {
        var viewModel = Login.Login.ViewModel()
        viewModel.user = response.user
        if let error = response.error {
            viewModel.errorMessage = ErrorHandler.SessionErrorHandler(error: error)
        }
        viewController?.displayLoginResult(viewModel: viewModel)
    }
    
    
}

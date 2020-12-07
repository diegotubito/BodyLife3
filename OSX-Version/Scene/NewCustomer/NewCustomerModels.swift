import Cocoa

enum NewCustomer {
    // MARK: Use cases
    
    enum NewCustomer {
        struct Request {
            var dni : String
            var newUser : CustomerModel.Customer
            var image : NSImage?
            var thumbnail : String?
        }
        struct Response {
            var error : ServerError?
            var customer : CustomerModel.Customer?
        }
        struct ViewModel {
            var customer: CustomerModel.Customer?
        }
    }

}

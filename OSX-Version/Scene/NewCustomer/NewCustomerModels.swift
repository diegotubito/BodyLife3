import Cocoa

enum NewCustomer {
    // MARK: Use cases
    
    enum NewCustomer {
        struct Request {
            var uid : String
            var childID : String
            var json : [String : Any]
        }
        struct Response {
            var error : ServerError?
            var userDecoded : UserDecoded?
        }
        struct ViewModel {
            var errorMessage : String?
            var userDecoded : UserDecoded?
        }
    }
}

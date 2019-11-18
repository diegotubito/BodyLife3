import Cocoa

enum NewCustomer {
    // MARK: Use cases
    
    enum NewCustomer {
        struct Request {
            var uid : String
            var childID : String
            var json : [String : Any]
            var image : NSImage
        }
        struct Response {
            var error : ServerError?
        }
        struct ViewModel {
            var errorMessage : ServerError?
        }
    }
}

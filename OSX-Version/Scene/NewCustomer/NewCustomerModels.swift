import Cocoa

enum NewCustomer {
    // MARK: Use cases
    
    enum NewCustomer {
        struct Request {
            var childID : String
            var dni : String
            var json : [String : Any]
            var image : NSImage
        }
        struct Response {
            var error : ServerError?
            var json : [String : Any]
        }
        struct ViewModel {
            var errorMessage : ServerError?
            var customer : BriefCustomer?
        }
    }

}

import Cocoa

enum Login {
    // MARK: Use cases
    
    enum Login {
        struct Request {
            var userName : String
            var password : String
        }
        struct Response {
            var error : ServerError?
            var user : FirebaseUserModel?
            var data : Data?
        }
        struct ViewModel {
            var errorMessage : String?
            var user : FirebaseUserModel?
            var data : Data?
        }
    }
}

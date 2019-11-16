import Cocoa

enum Login {
    // MARK: Use cases
    
    enum Login {
        struct Request {
            var userName : String
            var password : String
        }
        struct Response {
            var user : FirebaseUserModel?
            var error : AuthServiceError?
        }
        struct ViewModel {
            var user : FirebaseUserModel?
            var errorMessage : String?
        }
    }
}

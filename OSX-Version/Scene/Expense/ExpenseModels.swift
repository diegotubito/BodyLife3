import Cocoa

struct ExpenseType : Decodable {
    var childID : String
    var name : String
    var createdAt : Double
    var isEnabled : Bool
    var level : Int
    var childIDType : String?
}

enum Expense {
    // MARK: Use cases
    
    enum Types {
        struct Request {
            
        }
        struct Response {
            var types : [ExpenseType]?
            var error : Error?
        }
        struct ViewModel {
            var baseTypeTitles : [ExpenseType]?
            var secondaryTypeTitles : [ExpenseType]?
            var errorMessage : String?
        }
    }
    
    enum Save {
        struct Request {
            var register : [String : Any]
        }
        
        struct Response {
            var error : ServerError?
        }
        
        struct ViewModel {
            var errorMessage : String?
        }
    }
}

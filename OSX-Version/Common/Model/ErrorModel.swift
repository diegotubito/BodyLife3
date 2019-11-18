//
//  ErrorModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

enum AuthServiceError {
    case server_error
    case unknown_error
    case empty_user_data
    case serializationError
}

enum ServerError: Error {
    case server_error
    case unknown_error
    case unknown_auth_error
    case emptyData
    case invalidToken
    case tokenNotProvided
    case body_serialization_error
    case firebase_connection_error
    case notFound
    case error500
    
    case auth_wrong_password
    case auth_too_many_wrong_password
    case auth_invalid_email
    case auth_user_not_found
    
    case duplicated
    
}

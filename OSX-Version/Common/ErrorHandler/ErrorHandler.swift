//
//  ErrorHandler.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 10/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

class ErrorHandler {
    static let Shared = ErrorHandler()
    
    static func Server(error: ServerError) -> String {
        switch error {
        case .server_error:
            return "No se pudo establecer comunicación con el servidor."
        case .body_serialization_error:
            return "Error de serialización en parametros."
        case .firebase_connection_error:
            return "No se pudo establecer comunicación con firebase."
        case .invalidToken, .tokenNotProvided:
            return "Token invalido o vencido."
        case .notFound :
            return "Url no encontrada."
        case .error500 :
            return "Error 500"
        case .auth_wrong_password, .auth_user_not_found:
            return "Nombre de usuario o clave incorrecta."
        case .auth_too_many_wrong_password:
            return "Demasiados intentos, probá más tarde."
        case .auth_invalid_email:
            return "Formato de usuario incorrecto."
            
        default:
            break
        }
        return "Error desconocido"
    }
}

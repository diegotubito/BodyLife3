//
//  TextFieldValidation.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 17/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension NewCustomerViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        return true
    }
    
    func controlTextDidChange(_ obj: Notification) {
        areAllValid()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        areAllValid()
        
        if let textField = obj.object as? NSTextField {
            
            isValid(textField: textField)
            
        }
    }
    
    func isValid(textField: NSTextField) {
        
        switch textField {
        case dniTF:
            ValidateDNI() ? (dniLabel.stringValue = "") : (dniLabel.stringValue = "x")
        case apellidoTF:
            ValidateApellido() ? (apellidoLabel.stringValue = "") : (apellidoLabel.stringValue = "x")
        case nombreTF:
            ValidateNombre() ? (nombreLabel.stringValue = "") : (nombreLabel.stringValue = "x")
        case telefonoPrincipalTF:
            ValidateTelefonoPrimario() ? (telefonoPrincipalLabel.stringValue = "") : (telefonoPrincipalLabel.stringValue = "x")
            
        case telefonoSecundarioTF:
            ValidateTelefonoSecundario() ? (telefonoSecundarioLabel.stringValue = "") : (telefonoSecundarioLabel.stringValue = "x")
        case direccionTF:
            ValidateDireccion() ? (direccionLabel.stringValue = "") : (direccionLabel.stringValue = "x")
        case obraSocialTF:
            ValidateObraSocial() ? (obraSocialLabel.stringValue = "") : (obraSocialLabel.stringValue = "x")
        case emailTF:
            ValidateEmail() ? (emailLabel.stringValue = "") : (emailLabel.stringValue = "x")
        default:
            break
        }
    }
    
    func areAllValid() {
        guardarButtonOutlet.isEnabled = false
        
        if !ValidateDNI() {
            return
        }
        
        if !ValidateApellido() {
            return
        }
        
        if !ValidateNombre() {
            return
        }
        
        if !ValidateEmail() {
            return
        }
        
        if !ValidateDireccion() {
            return
        }
        if !ValidateTelefonoPrimario() {
            return
        }
        if !ValidateTelefonoSecundario() {
            return
        }
        if !ValidateObraSocial() {
            return
        }
        
        guardarButtonOutlet.isEnabled = true
        
    }
    
    func ValidateDNI() -> Bool {
        return ValidationField.IsValid(text: dniTF.stringValue, type: .Numeric, minChar: 8, maxChar: 11)
    }
    
    func ValidateApellido() -> Bool {
        return ValidationField.IsValid(text: apellidoTF.stringValue, type: .Alpha, minChar: 3, maxChar: 30)
    }
    
    func ValidateNombre() -> Bool {
        return ValidationField.IsValid(text: nombreTF.stringValue, type: .Alpha, minChar: 3, maxChar: 30)
    }
    
    func ValidateDireccion() -> Bool {
        return ValidationField.IsValid(text: direccionTF.stringValue, type: .AlphaNumeric, minChar: 0, maxChar: 100)
    }
    
    func ValidateTelefonoPrimario() -> Bool {
        return ValidationField.IsValid(text: telefonoPrincipalTF.stringValue, type: .Numeric, minChar: 0, maxChar: 15)
    }
    
    func ValidateTelefonoSecundario() -> Bool {
        return ValidationField.IsValid(text: telefonoSecundarioTF.stringValue, type: .Numeric, minChar: 0, maxChar: 15)
    }
    func ValidateObraSocial() -> Bool {
        return ValidationField.IsValid(text: obraSocialTF.stringValue, type: .AlphaNumeric, minChar: 0, maxChar: 50)
    }
    func ValidateEmail() -> Bool {
        return ValidationField.IsValid(text: emailTF.stringValue, type: .Email, minChar: 0, maxChar: 30)
    }
    
    func firstResponder(textField: NSTextField) {
        DispatchQueue.main.async {
            textField.becomeFirstResponder()
        }
        
    }
    
    
}

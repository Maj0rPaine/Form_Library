//
//  Validation.swift
//  Form_Library
//
//  Created by Chris Paine on 5/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import SwiftValidator

enum Rules {
    case required
    case email
    case password
    case confirm(field: UITextField)
    case date
    case zip
    case ssn
    case phone
}

class FormValidation {
    private var validator: Validator = Validator()
    
    private var registeredFields: [FormField] = []
    
    private var hasErrors: Bool {
        return !registeredFields.filter { $0.notValid }.isEmpty
    }
    
    var isValid: ((Bool) -> ())?
    
    init() {}
    
    private func build(_ rules: [Rules]) -> [Rule] {
        var validationRules: [Rule] = []
        
        for r in rules {
            switch r {
            case .required: validationRules.append(RequiredRule())
            case .email: validationRules.append(EmailRule())
            case .password: validationRules.append(PasswordRule())
            case .confirm(let field): validationRules.append(ConfirmationRule(confirmField: field))
            case .date: validationRules.append(DateRule())
            case .zip: validationRules.append(ZipCodeRule())
            case .ssn: validationRules.append(SSNRule())
            case .phone: validationRules.append(PhoneRule())
            }
        }
        
        return validationRules
    }
    
    // MARK: - Swift Validator methods
    
    func register(_ field: FormField) {
        validator.registerField(field, rules: build(field.rules))
    }
    
    func validateForm(_ completion: (([String]?) -> ())? = nil) {
        validator.validate { errors in
            guard !errors.isEmpty else {
                completion?(nil)
                return
            }
            
            for (field, error) in errors {
                if let field = field as? FormField {
                    field.setErrorMessage(error.errorMessage)
                }
            }
            
            completion?(errors.map { $0.1.errorMessage })
        }
    }
    
    func validateField(_ field: FormField) {
        validator.validateField(field) { error in
            field.setErrorMessage(error?.errorMessage ?? "")
            
            updateValidationState()
        }
    }
    
    // MARK: - Helper
    
    func observe(_ field: FormField) {
        register(field)
        registeredFields.append(field)
    }
    
    private func updateValidationState() {
        isValid?(!hasErrors)
    }
}

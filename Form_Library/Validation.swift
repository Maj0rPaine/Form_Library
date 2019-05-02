//
//  Validation.swift
//  Form_Library
//
//  Created by Chris Paine on 5/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import SwiftValidator

// MARK: - Validatables

enum FormValidatableState {
    case pristine
    case valid
    case invalid(message: String)
    
    var message: String {
        switch self {
        case .invalid(let message):
            return message
        default:
            return ""
        }
    }
}

protocol FormValidatable: class {
    var rules: [Rules] { get set }
    
    var inputState: FormValidatableState { get set }
}

// MARK: - Validation

struct FormValidationError {
    var field: UITextField?
    var message: String?
}

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

struct FormValidation: ValidationDelegate {
    private var validator: Validator = Validator()
    
    private var didValidate: ((_ errors: [FormValidationError]?) -> ())?
    
    init() {}
    
    init(didValidate: @escaping (_ errors: [FormValidationError]?) -> ()) {
        self.didValidate = didValidate
    }
    
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
    
    func register(_ field: FormField) {
        validator.registerField(field, rules: build(field.rules))
    }
    
    func validate() {
        validator.validate(self)
    }
    
    func validateField(_ field: FormField) {
        validator.validateField(field) { error in
            if error == nil {
                field.inputState = .valid
            } else {
                field.inputState = .invalid(message: error?.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - SwiftValidator delegate
    
    internal func validationSuccessful() {
        didValidate?(nil)
    }
    
    internal func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        dump(errors.map { $0.1.errorMessage })
        var validationErrors: [FormValidationError] = []
       
        for (field, error) in errors {
            if let field = field as? FormField {
                field.inputState = .invalid(message: error.errorMessage)
            }
            validationErrors.append(FormValidationError(field: field as? UITextField, message: error.errorMessage))
        }
        
        didValidate?(validationErrors)
    }
}

// MARK - Custom Rules

class PasswordRule: RegexRule {
    static let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@$!%*?&])[A-Za-z0-9@$!%*?&]{8,}$"
    convenience init(message: String = "Not a valid password") {
        self.init(regex: PasswordRule.regex, message: message)
    }
}

class DateRule: RegexRule {
    // covers 1800 1900 and 2000 centuries
    // did this because support requires a person to have a max age of 138 years old for date of birth.
    static let regex = "^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20|18)\\d\\d$"
    
    convenience init(message: String = "Not a valid date") {
        self.init(regex: DateRule.regex, message: message)
    }
}

class SSNRule: RegexRule {
    static let regex = "^\\d{3}-\\d{2}-\\d{4}$"
    
    convenience init(message : String = "Not a valid SSN"){
        self.init(regex: SSNRule.regex, message : message)
    }
}

class PhoneRule: RegexRule {
    static let regex = "^\\d{3}-\\d{3}-\\d{4}$"
    
    convenience init(message : String = "Not a valid phone number"){
        self.init(regex: PhoneRule.regex, message : message)
    }
}

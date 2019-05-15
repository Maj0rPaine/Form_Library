//
//  Validatables.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

enum ValidatableState: Equatable {
    case pristine
    case dirty
    case valid
    case invalid(message: String)
    
    var message: String {
        get {
            if case .invalid(let message) = self {
                return message
            } else {
                return ""
            }
        } set {
            if newValue.isEmpty {
                self = .valid
            } else {
                self = .invalid(message: newValue)
            }
        }
    }
    
    var shouldValidate: Bool {
        return self != .pristine
    }
    
    var notValid: Bool {
        switch self {
        case .invalid(_):
            return true
        default:
            return false
        }
    }
}

protocol Validatable: class {
    var rules: [Rules] { get set }
    
    var inputState: ValidatableState { get set }
}

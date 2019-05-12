//
//  Validatables.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

enum ValidatableState {
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
        if case .pristine = self {
            return false
        }
        return true
    }
}

protocol Validatable: class {
    var rules: [Rules] { get set }
    
    var inputState: ValidatableState { get set }
}

//
//  FormField.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class FormField: UITextField, Validatable {    
    var rules: [Rules] = []
    
    var inputState: ValidatableState = .pristine {
        didSet {
            switch inputState {
            case .invalid(let message):
                errorLabel.text = message
                break
            default:
                errorLabel.text = nil
                break
            }
        }
    }
    
    var shouldValidate: Bool { return inputState.shouldValidate }
    
    var notValid: Bool { return inputState.notValid }
    
    private var isInitialEdit: Bool {
        guard let newText = text,
            !newText.isEmpty,
            inputState == .pristine else { return false }
        return true
    }
    
    override var text: String? {
        didSet {
            if isInitialEdit {
                inputState = .dirty
            }
        }
    }
    
    private var maskedListener: MaskedListener?
    
    private var errorLabel: FormErrorLabel = FormErrorLabel()
    
    convenience init(rules: [Rules], mask: String? = nil, notations: MaskedNotations? = nil, placeholder: String? = nil, keyboardType: UIKeyboardType = .default) {
        self.init()
        self.rules = rules
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(errorLabel)
        errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
        if let mask = mask {
            maskedListener = MaskedListener()
            delegate = maskedListener?.setMask(mask, notations: notations)
        }
    }
    
    func setErrorMessage(_ message: String) {
        inputState.message = message
    }
}

//
//  Masks.swift
//  Form_Library
//
//  Created by Chris Paine on 5/3/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import InputMask

typealias MaskedNotations = [Notation]

extension String {
    func applyMask(mask: Mask) -> String {
        let result: Mask.Result = mask.apply(toText: CaretString.init(string: self))
        return result.formattedText.string
    }
}

enum MaskedFormat: String {
    case phoneFormat = "[000]-[000]-[0000]"
    case ssnFormat = "[000]-[00]-[0000]"
    case dateFormat = "[00]/[00]/[0000]"
    case zipFormat = "[00000]"
    case currencyFormat = "[999999999][.][99]"
    
    static let phone: Mask = try! Mask(format: MaskedFormat.phoneFormat.rawValue)
    static let ssn: Mask = try! Mask(format: MaskedFormat.ssnFormat.rawValue)
}

class MaskedFormField: FormField {
    private var listener = MaskedTextInputListener()

    convenience init(rules: [Rules],
                     placeholder: String? = nil,
                     keyboardType: UIKeyboardType = .default,
                     mask: MaskedFormat,
                     notations: MaskedNotations? = nil) {
        self.init(rules: rules, placeholder: placeholder, keyboardType: keyboardType)
       
        listener.primaryMaskFormat = mask.rawValue
        
        if let notations = notations {
            listener.customNotations = notations
        }
        
        delegate = listener
    }
}

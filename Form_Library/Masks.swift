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

struct MaskedFormat {
    static let phoneFormat: String = "[000]-[000]-[0000]"
    static let ssnFormat: String = "[000]-[00]-[0000]"
    static let dateFormat: String = "[00]/[00]/[0000]"
    static let zipFormat: String = "[00000]"
    static let currencyFormat: String = "[999999999][.][99]"
    
    static let phone: Mask = try! Mask(format: MaskedFormat.phoneFormat)
    static let ssn: Mask = try! Mask(format: MaskedFormat.ssnFormat)
}

struct MaskedNotation {
    static let decimalNotation: Notation = Notation(character: ".", characterSet: CharacterSet(charactersIn: "."), isOptional: true)
}

struct MaskedListener {
    private var listener = MaskedTextInputListener()
    
    func setMask(_ mask: String, notations: MaskedNotations?) -> MaskedTextInputListener {
        listener.primaryMaskFormat = mask
        
        if let notations = notations {
            listener.customNotations = notations
        }
        
        return listener
    }
}

//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit
import Validator

enum Menu {
    case option1
    case option2
    case option3
    
    static let all: [Menu] = [.option1, .option2, .option3]
    
    var text: String {
        switch self {
        case .option1: return "Option 1"
        case .option2: return "Option 2"
        case .option3: return "Option 3"
        }
    }
}

struct ValidatorForm: Validatable {
    enum Errors: String, Error {
        case fieldRequired = "Field is required"
        var message: String { return self.rawValue }
    }
    
    static let minLengthRule = ValidationRuleLength(min: 1, error: Errors.fieldRequired)
}

struct TestForm {
    var isEnabled: Bool = true
    var showPreview: Menu = .option1
    var nestedTextField: String = "Text Here"
    var inlineTextField: String = ""
    
    var enabledSectionTitle: String? {
        return isEnabled ? "Row Enabled" : nil
    }

    var isValid: Bool {
        return inlineTextField.validate(rule: ValidatorForm.minLengthRule).isValid
    }
}

let formMenu: Form<TestForm> = sections([
    section(
        Menu.all.map { option in
            optionCell(title: option.text, option: option, keyPath: \.showPreview)
        }
    )
])

let formSections: Form<TestForm> = sections([
    section([
        controlCell(title: "Switch", control: uiSwitch(keyPath: \.isEnabled))
    ], footer: \TestForm.enabledSectionTitle),
    section([
        detailTextCell(title: "Menu", keyPath: \.showPreview.text, form: formMenu)
    ]),
    section([
        nestedTextField(title: "Nested Text Field", keyPath: \.nestedTextField),
    ]),
    section([
        controlCell(title: "Inline Text Field", control: uiTextField(keyPath: \.inlineTextField)),
    ])
])

class ValidatingFormDriver<State>: FormDriver<State> {
    init(initial state: State, build: Element<[Section], State>, title: String) {
        super.init(initial: state, build: build)
        
        self.formViewController.title = title
        self.formViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveForm))
    }
    
    @objc func saveForm() {
        dump(state)
        
        if let testForm = state as? TestForm, testForm.isValid {
            // TODO:
        }
    }
}

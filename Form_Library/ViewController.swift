//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

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

struct TestForm {
    var isEnabled: Bool = true
    var showPreview: Menu = .option1
    var nestedTextField: String = "Text Here"
    var inlineTextField: String = "Text Here"
}

extension TestForm {
    var enabledSectionTitle: String? {
        return isEnabled ? "Row Enabled" : nil
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

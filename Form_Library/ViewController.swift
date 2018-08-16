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
    
    static let all: [Menu] = [.option1, .option3, .option2]
    
    var text: String {
        switch self {
        case .option1: return "Option 1"
        case .option3: return "Option 2"
        case .option2: return "Option 3"
        }
    }
}

struct TestForm {
    var isEnabled: Bool = true
    var showPreview: Menu = .option1
    var row1: String = "Text Here"
    var row2: String = "Text Here"
}

extension TestForm {
    var enabledSectionTitle: String? {
        return isEnabled ? "Row Enabled" : nil
    }
}

let menuForm: Form<TestForm> = sections([
    section(
        Menu.all.map { option in
            optionCell(title: option.text, option: option, keyPath: \.showPreview)
        }
    )
])

let testForm: Form<TestForm> = sections([
    section([
        controlCell(title: "Switch Row", control: uiSwitch(keyPath: \.isEnabled))
    ], footer: \TestForm.enabledSectionTitle),
    section([
        detailTextCell(title: "Menu Row", keyPath: \.showPreview.text, form: menuForm)
    ]),
    section([
        nestedTextField(title: "Text Field Row", keyPath: \.row1),
        nestedTextField(title: "Text Field Row", keyPath: \.row2)
    ])
])

func saveBarButton<State>() -> Element<UIBarButtonItem, State> {
    return { context in
        let target = TargetAction {
            context.save()
        }
        let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: target, action: #selector(TargetAction.action(_:)))
        return RenderedElement(
            element: saveBarButton,
            strongReferences: [target],
            update: { state in
                // TODO: Activity indicator?
                print(state)
        })
    }
}

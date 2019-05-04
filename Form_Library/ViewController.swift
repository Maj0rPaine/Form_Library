//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 4/29/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

//enum ShowPreview {
//    case always
//    case never
//    case whenUnlocked
//
//    static let all: [ShowPreview] = [.always, .whenUnlocked, .never]
//
//    var text: String {
//        switch self {
//        case .always: return "Always"
//        case .whenUnlocked: return "When Unlocked"
//        case .never: return "Never"
//        }
//    }
//}
//
//struct Hotspot {
//    var isEnabled: Bool = true
//    var password: String = "hello"
//    var networkName: String = "My Network"
//    var showPreview: ShowPreview = .always
//}
//
//extension Hotspot {
//    var enabledSectionTitle: String? {
//        return isEnabled ? "Personal Hotspot Enabled" : nil
//    }
//}
//
//struct Settings {
//    var hotspot = Hotspot()
//
//    var hotspotEnabled: String {
//        return hotspot.isEnabled ? "On" : "Off"
//    }
//}
//
//let showPreviewForm: Form<Hotspot> =
//    sections([
//        section(
//            ShowPreview.all.map { option in
//                optionCell(title: option.text, option: option, keyPath: \.showPreview)
//            }
//        )
//    ])
//
//let hotspotForm: Form<Hotspot> =
//    sections([
//        section([
//            controlCell(title: "Personal Hotspot", control: formSwitch(keyPath: \.isEnabled))
//        ], footer: \Hotspot.enabledSectionTitle),
//        section ([
//            detailTextCell(title: "Notification", keyPath: \.showPreview.text, form: showPreviewForm)
//        ], isVisible: \.isEnabled),
//        section([
//            nestedTextField(title: "Password", keyPath: \.password),
//            nestedTextField(title: "Network Name", keyPath: \.networkName)
//        ], isVisible: \.isEnabled)
//    ])
//
//let settingsForm: Form<Settings> =
//    sections([
//        section([
//            detailTextCell(title: "Personal Hotspot", keyPath: \Settings.hotspotEnabled, form: bind(form: hotspotForm, to: \.hotspot))
//        ])
//    ])

struct PersonalInfo {
    var firstName: String = ""
    var lastName: String = ""
    var ssn: String = ""
    var birthdate: String = ""
    var phone: String = ""
    var address: Address = Address()
}

struct Address {
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
}

let form: Form<PersonalInfo> =
    sections([
        section([
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "First Name"), keyPath: \.firstName)),
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "Last Name"), keyPath: \.lastName)),
            validatingCell(control: formTextField(textField: FormField(rules: [.ssn], mask: MaskedFormat.ssnFormat, placeholder: "SSN", keyboardType: .decimalPad), keyPath: \.ssn)),
            validatingCell(control: formTextField(textField: FormField(rules: [.date], mask: MaskedFormat.dateFormat, placeholder: "Birthdate", keyboardType: .decimalPad), keyPath: \.birthdate)),
            validatingCell(control: formTextField(textField: FormField(rules: [.phone], mask: MaskedFormat.phoneFormat, placeholder: "Phone Number", keyboardType: .decimalPad), keyPath: \.phone)),
        ]),
        section([
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "Street"), keyPath: \.address.street)),
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "City"), keyPath: \.address.city)),
            validatingCell(control: formPickerField(formPicker: FormPicker(with: ["A"], textField: FormField(rules: [.required], placeholder: "State")), keyPath: \.address.state)),
            validatingCell(control: formTextField(textField: FormField(rules: [.zip], placeholder: "Zip Code", keyboardType: .decimalPad), keyPath: \.address.zip))
            ])
    ])

let driver = TestFormDriver(initial: PersonalInfo(), build: form, title: "Test Form")

class TestFormDriver<State>: FormDriver<State> {
    override init(initial state: State, build: Element<[Section], State>, title: String) {
        super.init(initial: state, build: build)
        
        self.formViewController.title = title
        
        self.formViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveForm))
    }
    
    @objc func saveForm() {
        dump(state)
        self.formValidation.validate()
    }
}

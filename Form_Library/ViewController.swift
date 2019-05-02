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
    var phone: String = ""
    var birthdate: String = Date().short() ?? ""
}

struct DriversLicense {
    var dlNumber: String = ""
    var dlState: String = ""
}

let form: Form<PersonalInfo> =
    sections([
        section([
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "First Name"), keyPath: \.firstName)),
            validatingCell(control: formTextField(textField: FormField(rules: [.required], placeholder: "Last Name"), keyPath: \.lastName)),
            validatingCell(control: formTextField(textField: FormField(rules: [.phone], mask: MaskedFormat.phoneFormat, placeholder: "xxx-xxx-xxxx", keyboardType: .decimalPad), keyPath: \.phone)),
            validatingCell(control: formTextField(textField: FormField(rules: [.date], placeholder: "mm/dd/yyyy", keyboardType: .decimalPad), keyPath: \.birthdate))
            //validatingCell(control: formPicker(formPicker: FormPicker(with: ["A", "B", "C", "D"], textField: FormField(rules: [.required], placeholder: "State")), keyPath: \.dlState))
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

extension Date {
    static func fromShort(str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from:str)
    }
    
    func short() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
}

//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

/// Manages state of form
struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

final class TargetAction {
    let execute: () -> ()
    
    // Init with callback
    init(_ execute: @escaping() -> ()) {
        self.execute = execute
    }
    @objc func action(_ sender: Any) {
        execute()
    }
}

/// HotspotForm observer that manages strong references and update functions
struct Observer {
    var strongReferences: [Any]
    var update: (Hotspot) -> ()
}

/**
 Free function passed into driver init() that sets up strong references and update functions.
 - Parameters:
    - state: Hotspot struct
    - change: Function that performs change on original struct
    - pushViewController: Function that pushes a view controller onto stack
 - Returns: Tuple containing an array of sections and Observer struct
 */
func hotspotForm(state: Hotspot, change: @escaping ((inout Hotspot) -> ()) -> (), pushViewController: @escaping (UIViewController) -> ()) -> ([Section], Observer) {
    var strongReferences: [Any] = []
    var updates: [(Hotspot) -> ()] = []
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    let toggle = UISwitch()
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addSubview(toggle)
    toggle.isOn = state.isEnabled
    toggle.translatesAutoresizingMaskIntoConstraints = false
    
    let toggleTarget = TargetAction {
        change { $0.isEnabled = toggle.isOn }
    }
    
    // Append toggle target as a strong reference
    strongReferences.append(toggleTarget)
    
    toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
    toggleCell.contentView.addConstraints([
        toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
    ])
    
    // Append function to update toggle
    updates.append { state in
        toggle.isOn = state.isEnabled
    }
    
    let toggleSection = Section(cells: [toggleCell], footerTitle: state.enabledSectionTitle)
    
    // Append function to update footer
    updates.append { state in
        toggleSection.footerTitle = state.enabledSectionTitle
    }
    
    let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
    passwordCell.textLabel?.text = "Password"
    passwordCell.detailTextLabel?.text = state.password
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.shouldHighlight = true
    
    // Append function to set password in detail label
    updates.append { state in
        passwordCell.detailTextLabel?.text = state.password
    }

    let passwordDriver = PasswordDriver(password: state.password) { newPassword in
        change { $0.password = newPassword }
    }

    passwordCell.didSelect = {
        pushViewController(passwordDriver.formViewController)
    }
    
    let passwordSection = Section(cells: [passwordCell], footerTitle: nil)
    
    return ([
        toggleSection,
        passwordSection
    ], Observer(strongReferences: strongReferences) { state in
        // Aggregate of the update functions
        for u in updates {
            u(state)
        }
    })
}

class FormDriver {
    var formViewController: FormViewController!
    var sections: [Section] = []
    var observer: Observer!
    
    // Initialize with free function hotspotForm
    init(initial state: Hotspot, build: (Hotspot, @escaping ((inout Hotspot) -> ()) -> (), _ pushViewController: @escaping (UIViewController) -> ()) -> ([Section], Observer)) {
        self.state = state
        
        // Call build function, passing in state, change function, and push function
        let (sections, observer) = build(state, { [unowned self] f in
            f(&self.state) // Mutate state
        }, { [unowned self] vc in
            self.formViewController.navigationController?.pushViewController(vc, animated: true)
        })
        self.sections = sections
        self.observer = observer
        formViewController = FormViewController(sections: sections, title: "Personal Hotspot Settings")
    }
    
    var state = Hotspot() {
        didSet {
            observer.update(state)
            formViewController.reloadSectionFooters()
        }
    }
}

class PasswordDriver {
    let textField = UITextField()
    let onChange: (String) -> ()
    var formViewController: FormViewController!
    var sections: [Section] = []
    
    init(password: String, onChange: @escaping (String) -> ()) {
        self.onChange = onChange
        buildSections()
        self.formViewController = FormViewController(sections: sections, title: "Hotspot Password", firstResponder: textField)
        textField.text = password
    }
    
    func buildSections() {
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Password"
        cell.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(editingField(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(editingDidEnter(_:)), for: .editingDidEndOnExit)
        cell.contentView.addConstraints([
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
    
        sections = [
            Section(cells: [cell], footerTitle: nil)
        ]
    }
    
    @objc func editingField(_ sender: Any) {
        onChange(textField.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender: Any) {
        onChange(textField.text ?? "")
        formViewController.navigationController?.popViewController(animated: true)
    }
}

//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

/// Hotspot settings
struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

/**
 Free function that builds form for settings.
 - Parameters:
    - context: RenderingContext struct
 - Returns: Tuple containing cell sections and form observer
 */
func hotspotForm(context: RenderingContext<Hotspot>) -> ([Section], Observer<Hotspot>) {
    var strongReferences: [Any] = []
    var updates: [(Hotspot) -> ()] = []
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    let toggle = UISwitch()
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addSubview(toggle)
    toggle.translatesAutoresizingMaskIntoConstraints = false
    
    let toggleTarget = TargetAction {
        context.change { $0.isEnabled = toggle.isOn }
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
    
    let toggleSection = Section(cells: [toggleCell], footerTitle: nil)
    
    // Append function to update footer
    updates.append { state in
        toggleSection.footerTitle = state.enabledSectionTitle
    }
    
    let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
    passwordCell.textLabel?.text = "Password"
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.shouldHighlight = true
    
    // Append function to set password in detail label
    updates.append { state in
        passwordCell.detailTextLabel?.text = state.password
    }

    // Build nested password form
    let (sections, observer) = buildPasswordForm(context: context)
    let nested = FormViewController(sections: sections, title: "Personal Hotspot Password")

    passwordCell.didSelect = {
        context.pushViewController(nested)
    }
    
    let passwordSection = Section(cells: [passwordCell], footerTitle: nil)
    let combinedStrongReferences = strongReferences + observer.strongReferences
    
    return ([
        toggleSection,
        passwordSection
    ], Observer(strongReferences: combinedStrongReferences) { state in
        // Update nested form's observers
        observer.update(state)
        
        // Aggregate of the update functions
        for u in updates {
            u(state)
        }
    })
}

/**
 Builds password form with one text field cell.
 - Parameters:
    - context: RenderingContext struct
 - Returns: Tuple containing cell section and form observer.
 */
func buildPasswordForm(context: RenderingContext<Hotspot>) -> ([Section], Observer<Hotspot>) {
    let textField = UITextField()
    
    // Use function type since there is only one update
    let update: (Hotspot) -> () = { state in
        textField.text = state.password
    }
    
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    cell.contentView.addSubview(textField)
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    let ta1 = TargetAction {
        context.change { $0.password = textField.text ?? "" }
    }
    
    let ta2 = TargetAction {
        context.change { $0.password = textField.text ?? "" }
        context.popViewController()
    }
    
    textField.addTarget(ta1, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
    textField.addTarget(ta2, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
    
    cell.contentView.addConstraints([
        textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        textField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
    
    return ([
        Section(cells: [cell], footerTitle: nil)
    ], Observer(strongReferences: [ta1, ta2], update: update))
}

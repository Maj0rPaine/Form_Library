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
func hotspotForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    var strongReferences: [Any] = []
    var updates: [(Hotspot) -> ()] = []
    
    let renderedToggle = uiSwitch(context: context, keyPath: \Hotspot.isEnabled)
    strongReferences.append(contentsOf: renderedToggle.strongReferences)
    updates.append(renderedToggle.update)
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addSubview(renderedToggle.element)
    toggleCell.contentView.addConstraints([
        renderedToggle.element.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        renderedToggle.element.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
    ])
    
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
    let renderedPasswordForm = buildPasswordForm(context: context)
    let nested = FormViewController(sections: renderedPasswordForm.element, title: "Personal Hotspot Password")

    passwordCell.didSelect = {
        context.pushViewController(nested)
    }
    
    let passwordSection = Section(cells: [passwordCell], footerTitle: nil)

    return RenderedElement(
        element: [toggleSection, passwordSection],
        strongReferences: strongReferences + renderedPasswordForm.strongReferences,
        update: { state in
            // Update nested form's observers
            renderedPasswordForm.update(state)
            
            // Aggregate of the update functions
            for u in updates {
                u(state)
            }
        }
    )
}

/**
 Builds password form with one text field cell.
 - Parameters:
    - context: RenderingContext struct
 - Returns: Tuple containing cell section and form observer.
 */
func buildPasswordForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    let renderedPassword = uiTextField(context: context, keyPath: \Hotspot.password)
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    cell.contentView.addSubview(renderedPassword.element)
    cell.contentView.addConstraints([
        renderedPassword.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        renderedPassword.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        renderedPassword.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
    ])
    
    return RenderedElement(
        element: [Section(cells: [cell], footerTitle: nil)],
        strongReferences: renderedPassword.strongReferences,
        update: renderedPassword.update
    )
}

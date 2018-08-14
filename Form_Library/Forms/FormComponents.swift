//
//  FormComponents.swift
//  Form_Library
//
//  Created by Chris Paine on 8/14/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

/**
 Reusable switch component
 - Parameters:
 - context: RenderingContext
 - keyPath: WritableKeyPath
 */
func uiSwitch<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, Bool>) -> RenderedElement<UIView, State> {
    let toggle = UISwitch()
    toggle.translatesAutoresizingMaskIntoConstraints = false
    
    let toggleTarget = TargetAction {
        context.change { $0[keyPath: keyPath] = toggle.isOn }
    }
    toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
    
    return RenderedElement(
        element: toggle,
        strongReferences: [toggleTarget],
        update: { state in
            toggle.isOn = state[keyPath: keyPath]
        }
    )
}

/**
 Reusable text field component
 - Parameters:
 - context: RenderingContext
 - keyPath: WritableKeyPath
 */
func uiTextField<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, String>) -> RenderedElement<UIView, State> {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    let didEnd = TargetAction {
        context.change { $0[keyPath: keyPath] = textField.text ?? "" }
    }
    
    let didExit = TargetAction {
        context.change { $0[keyPath: keyPath] = textField.text ?? "" }
        context.popViewController()
    }
    
    textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
    textField.addTarget(didExit, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
    
    return RenderedElement(
        element: textField,
        strongReferences: [didEnd, didExit],
        update: { state in
            textField.text = state[keyPath: keyPath]
        }
    )
}

func controlCell<State>(title: String, control: RenderedElement<UIView, State>, leftAligned: Bool = false) -> RenderedElement<FormCell, State> {
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = title
    cell.contentView.addSubview(control.element)
    cell.contentView.addConstraints([
        control.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        control.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    
    if leftAligned {
        cell.contentView.addConstraints([
            control.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
            ])
    }
    
    return RenderedElement(
        element: cell,
        strongReferences: control.strongReferences,
        update: control.update
    )
}

func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, didSelect: @escaping () -> ()) -> RenderedElement<FormCell, State> {
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    cell.accessoryType = .disclosureIndicator
    cell.shouldHighlight = true
    cell.didSelect = didSelect
    return RenderedElement(
        element: cell,
        strongReferences: [],
        update: { state in
            cell.detailTextLabel?.text = state[keyPath: keyPath]
    }
    )
}

//
//  FormComponents.swift
//  Form_Library
//
//  Created by Chris Paine on 8/14/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

func uiSwitch<State>(keyPath: WritableKeyPath<State, Bool>) -> Element<UIView, State> {
    return { context in
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
}

func uiTextField<State>(keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
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
}

func controlCell<State>(title: String, control: @escaping Element<UIView, State>, leftAligned: Bool = false) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        let renderedControl = control(context)
        cell.textLabel?.text = title
        cell.contentView.addSubview(renderedControl.element)
        cell.contentView.addConstraints([
            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        if leftAligned {
            cell.contentView.addConstraints([
                renderedControl.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
                ])
        }
        
        return RenderedElement(
            element: cell,
            strongReferences: renderedControl.strongReferences,
            update: renderedControl.update
        )
    }
}

func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, form: @escaping Form<State>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.shouldHighlight = true
        
        let rendered = form(context)
        let nested = FormViewController(sections: rendered.element, title: title)
        cell.didSelect = {
            context.pushViewController(nested)
            
        }
        return RenderedElement(
            element: cell,
            strongReferences: rendered.strongReferences,
            update: { state in
                cell.detailTextLabel?.text = state[keyPath: keyPath]
                rendered.update(state)
        })
    }
}

func nestedTextField<State>(title: String, keyPath: WritableKeyPath<State, String>) -> Element<FormCell, State> {
    let nested: Form<State> = sections([
        section([controlCell(title: title, control: uiTextField(keyPath: keyPath), leftAligned: true)])
        ])
    return detailTextCell(title: title, keyPath: keyPath, form: nested)
}

func optionCell<Input: Equatable, State>(title: String, option: Input, keyPath: WritableKeyPath<State, Input>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.shouldHighlight = true
        cell.didSelect = {
            context.change { $0[keyPath: keyPath] = option }
        }
        return RenderedElement(element: cell, strongReferences: [], update: { state in
            cell.accessoryType = state[keyPath: keyPath] == option ? .checkmark : .none
        })
    }
}

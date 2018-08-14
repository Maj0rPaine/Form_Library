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

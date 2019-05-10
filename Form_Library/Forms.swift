//
//  Forms.swift
//  Form_Library
//
//  Created by Chris Paine on 4/29/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

typealias Form<A> = Element<[Any], A>
typealias Element<El, A> = (FormContext<A>) -> FormElement<El, A>
typealias Section<A> = Element<UIView, A>
typealias RenderedSection<A> = Element<TableSection, A>

struct FormContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let validation: FormValidation
}

struct FormElement<Element, State> {
    var element: Element
    var strongReferences: [Any]
    var update: (State) -> ()
}

class FormDriver<State> {
    private var formViewController: FormViewController?
    
    private var formElement: FormElement<[Any], State>!
    
    private var formValidation: FormValidation = FormValidation()
    
    var state: State {
        didSet {
            formElement.update(state)
            
            formViewController?.reloadSections()
        }
    }
    
    init(initial
        state: State,
        build: (FormContext<State>) -> FormElement<[Any], State>,
        title: String = "",
        presentingController: UIViewController? = nil) {
        self.state = state
        
        // Create form context
        let context = FormContext(
            state: state,
            change: { [unowned self] f in
                f(&self.state)
            },
            validation: formValidation
        )
        
        // Build form controls
        self.formElement = build(context)
        
        // Update form state
        formElement.update(state)
        
        // Set up form tvc
        if let renderedSections = formElement.element as? [TableSection] {
            formViewController = FormViewController(sections: renderedSections)
            presentingController?.renderChildTableViewController(controller: formViewController!)
            presentingController?.title = title
        }
    }
}

extension FormDriver {
    func validateForm(_ completion: @escaping (_ errors: [String]?) -> ()) {
        formValidation.validateForm(completion)
    }
}

//func bind<State, NestedState>(form: @escaping Form<NestedState>, to keyPath: WritableKeyPath<State, NestedState>) -> Form<State> {
//    return { context in
//        let nestedContext = RenderingContext<NestedState>(state: context.state[keyPath: keyPath], change: { nestedChange in
//            context.change { state in
//                nestedChange(&state[keyPath: keyPath])
//            }
//        }, pushViewController: context.pushViewController, popViewController: context.popViewController)
//        let sections = form(nestedContext)
//        return RenderedElement<[Section], State>(element: sections.element, strongReferences: sections.strongReferences, update: { state in
//            sections.update(state[keyPath: keyPath])
//        })
//    }
//}

// MARK: - Controls

final class TargetAction {
    let execute: () -> ()
    init(_ execute: @escaping() -> ()) {
        self.execute = execute
    }
    
    @objc func action(_ sender: Any) {
        execute()
    }
}

func formSwitch<State>(keyPath: WritableKeyPath<State, Bool>) -> Element<UIView, State> {
    return { context in
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        let toggleTarget = TargetAction {
            context.change { $0[keyPath: keyPath] = toggle.isOn }
        }
        toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
        return FormElement(element: toggle, strongReferences: [toggleTarget], update: { state in
            toggle.isOn = state[keyPath: keyPath]
        })
    }
}

func formTextField<State>(textField: FormField, keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let didEnd = TargetAction {
            context.validation.validateField(textField)
        }
        
        let didChange = TargetAction {
            context.change { $0[keyPath: keyPath] = textField.text ?? "" }
            
            if textField.shouldValidate {
                context.validation.validateField(textField)
            }
        }
        
        textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        textField.addTarget(didChange, action: #selector(TargetAction.action(_:)), for: .editingChanged)
    
        context.validation.register(textField)
        
        return FormElement(element: textField, strongReferences: [didEnd, didChange], update: { state in
            textField.text = state[keyPath: keyPath]
        })
    }
}

func formPickerField<State>(formPicker: FormPicker, keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let didUpdate = TargetAction {
            context.validation.validateField(formPicker.textField)
        }
        
        formPicker.didSelect = { value in
            context.change { $0[keyPath: keyPath] = value }
            context.validation.validateField(formPicker.textField)
        }
        
        formPicker.textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        formPicker.textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        
        context.validation.register(formPicker.textField)
        
        return FormElement(element: formPicker.textField, strongReferences: [didUpdate], update: { state in
            formPicker.selectRow(value: state[keyPath: keyPath])
            formPicker.textField.text = state[keyPath: keyPath]
        })
    }
}

func section<State>(_ section: [Section<State>]) -> Form<State> {
    return { context in
        let renderedSections = section.map { $0(context) }
        let strongReferences = renderedSections.flatMap { $0.strongReferences }
        let update: (State) -> () = { state in
            for c in renderedSections {
                c.update(state)
            }
        }
        return FormElement(element: renderedSections.map { $0.element }, strongReferences: strongReferences, update: update)
    }
}


//
//  Forms.swift
//  Form_Library
//
//  Created by Chris Paine on 4/29/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

typealias Form<A> = Element<[Section], A>
typealias Element<El, A> = (RenderingContext<A>) -> RenderedElement<El, A>
typealias RenderedSection<A> = Element<Section, A>

struct RenderingContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let observe: (FormField) -> ()
    let validate: (FormField) -> ()
    //let pushViewController: (UIViewController) -> ()
    //let popViewController: () -> ()
}

struct RenderedElement<Element, State> {
    var element: Element
    var strongReferences: [Any]
    var update: (State) -> ()
}

class FormDriver<State> {
    var formViewController: FormViewController!
    
    var rendered: RenderedElement<[Section], State>!
    
    var formValidation: FormValidation = FormValidation()
    
    var state: State {
        didSet {
            rendered.update(state)
            formViewController.reloadSections()
        }
    }
    
    // TODO: init with build closure that returns RenderedElement<[FormField], State>
    // This will allow you to use form driver with existing UI elements
    
    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>, title: String = "") {
        self.state = state
        
        // Create form context
        let context = RenderingContext(
            state: state,
            change: { [unowned self] f in
                f(&self.state)
            },
            observe: { [unowned self] field in
                self.formValidation.register(field)
            },
            validate: { [unowned self] field in
                self.formValidation.validateField(field)
            }
            //, pushViewController: { [unowned self] vc in
            //    self.formViewController.navigationController?.pushViewController(vc, animated: true)
            //}, popViewController: { [unowned self] in
            //    self.formViewController.navigationController?.popViewController(animated: true)
            //}
        )
        
        // Build form controls
        self.rendered = build(context)
        
        // Update form state
        rendered.update(state)
        
        // Set up form tvc
        formViewController = FormViewController(sections: rendered.element, title: title)
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
        return RenderedElement(element: toggle, strongReferences: [toggleTarget], update: { state in
            toggle.isOn = state[keyPath: keyPath]
        })
    }
}

func formTextField<State>(textField: FormField, keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let didUpdate = TargetAction {
            context.change { $0[keyPath: keyPath] = textField.text ?? "" }
            context.validate(textField)
        }
        
        textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingChanged)
    
        context.observe(textField)
        
        return RenderedElement(element: textField, strongReferences: [didUpdate], update: { state in
            textField.text = state[keyPath: keyPath]
        })
    }
}

func formPicker<State>(formPicker: FormPicker, keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let didUpdate = TargetAction {
            context.validate(formPicker.textField)
        }
        
        formPicker.didSelect = { value in
            context.change { $0[keyPath: keyPath] = value }
            context.validate(formPicker.textField)
        }
        
        formPicker.textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        formPicker.textField.addTarget(didUpdate, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        
        context.observe(formPicker.textField)
        
        return RenderedElement(element: formPicker.textField, strongReferences: [didUpdate], update: { state in
            formPicker.selectRow(value: state[keyPath: keyPath])
            formPicker.textField.text = state[keyPath: keyPath]
        })
    }
}

// MARK: - Cells

func validatingCell<State>(control: @escaping Element<UIView, State>) -> Element<FormCell, State> {
    return { context in
        let renderedControl = control(context)
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.detailTextLabel?.textColor = .red
        cell.contentView.addSubview(renderedControl.element)
        cell.contentView.addConstraints([
            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            renderedControl.element.leadingAnchor.constraint(equalTo:  cell.contentView.layoutMarginsGuide.leadingAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        return RenderedElement(element: cell, strongReferences: renderedControl.strongReferences, update: renderedControl.update)
    }
}

//func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, form: @escaping Form<State>) -> Element<FormCell, State> {
//    return { context in
//        let cell = FormCell(style: .value1, reuseIdentifier: nil)
//        cell.textLabel?.text = title
//        cell.accessoryType = .disclosureIndicator
//        cell.shouldHighlight = true
//
//        let rendered = form(context)
//        let nested = FormViewController(sections: rendered.element, title: title)
//        cell.didSelect = {
//            context.pushViewController(nested)
//        }
//        return RenderedElement(element: cell, strongReferences: rendered.strongReferences, update: { state in
//            cell.detailTextLabel?.text = state[keyPath: keyPath]
//            rendered.update(state)
//            nested.reloadSections()
//        })
//    }
//}
//
//func nestedTextField<State>(title: String, keyPath: WritableKeyPath<State, String>) -> Element<FormCell, State> {
//    let nested: Form<State> =
//        sections([
//            section([
//                controlCell(title: title, control: formTextField(keyPath: keyPath), leftAligned: true)
//                ])
//            ])
//    return detailTextCell(title: title, keyPath: keyPath, form: nested)
//}
//
//func controlCell<State>(title: String, control: @escaping Element<UIView, State>, leftAligned: Bool = false) -> Element<FormCell, State> {
//    return { context in
//        let renderedControl = control(context)
//        let cell = FormCell(style: .value1, reuseIdentifier: nil)
//        cell.textLabel?.text = title
//        cell.contentView.addSubview(renderedControl.element)
//        cell.contentView.addConstraints([
//            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
//            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
//            ])
//
//        if leftAligned {
//            cell.contentView.addConstraint(renderedControl.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20))
//        }
//
//        return RenderedElement(element: cell, strongReferences: renderedControl.strongReferences, update: renderedControl.update)
//    }
//}
//
//func optionCell<Input: Equatable, State>(title: String, option: Input, keyPath: WritableKeyPath<State, Input>) -> Element<FormCell, State> {
//    return { context in
//        let cell = FormCell(style: .value1, reuseIdentifier: nil)
//        cell.textLabel?.text = title
//        cell.shouldHighlight = true
//        cell.didSelect = {
//            context.change { $0[keyPath: keyPath] = option }
//        }
//        return RenderedElement(element: cell, strongReferences: [], update: { state in
//            cell.accessoryType = state[keyPath: keyPath] == option ? .checkmark : .none
//        })
//    }
//}

// MARK: - Sections

func section<State>(_ cells: [Element<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil, isVisible: KeyPath<State, Bool>? = nil) -> RenderedSection<State> {
    return { context in
        let renderedCells = cells.map { $0(context) }
        let strongReferences = renderedCells.flatMap { $0.strongReferences }
        let section = Section(cells: renderedCells.map { $0.element }, footerTitle: nil, isVisible: true)
        let update: (State) -> () = { state in
            for c in renderedCells {
                c.update(state)
            }
            if let kp = keyPath {
                section.footerTitle = state[keyPath: kp]
            }
            if let iv = isVisible {
                section.isVisible = state[keyPath: iv]
            }
        }
        return RenderedElement(element: section, strongReferences: strongReferences, update: update)
    }
}

func sections<State>(_ sections: [RenderedSection<State>]) -> Form<State> {
    return { context in
        let renderedSections = sections.map { $0(context) }
        let strongReferences = renderedSections.flatMap { $0.strongReferences }
        let update: (State) -> () = { state in
            for c in renderedSections {
                c.update(state)
            }
        }
        return RenderedElement(element: renderedSections.map { $0.element }, strongReferences: strongReferences, update: update)
    }
}


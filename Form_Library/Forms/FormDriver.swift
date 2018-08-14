//
//  FormDriver.swift
//  Form_Library
//
//  Created by Chris Paine on 8/14/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

/// Action method with callback for target selector.
final class TargetAction {
    let execute: () -> ()
    init(_ execute: @escaping() -> ()) {
        self.execute = execute
    }
    @objc func action(_ sender: Any) {
        execute()
    }
}

/// Generic observer that manages strong references and update functions.
struct RenderedElement<Element, State> {
    var element: Element
    var strongReferences: [Any]
    var update: (State) -> ()
}

/// Generic renderingContext holds state, form changes, and actions.
struct RenderingContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let pushViewController: (UIViewController) -> ()
    let popViewController: () -> ()
}

/// Generic form driver renders form context and observes changes.
class FormDriver<State> {
    var formViewController: FormViewController!
    var rendered: RenderedElement<[Section], State>!
    
    var state:State {
        didSet {
            rendered.update(state)
            formViewController.reloadSectionFooters()
        }
    }
    
    // Initialize with free function hotspotForm.
    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>) {
        self.state = state
        
        // Create rendering context with state, change and push functions
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state) // Mutate state
            }, pushViewController: { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: { [unowned self] in
                self.formViewController.navigationController?.popViewController(animated: true)
        })
        
        self.rendered = build(context)
        rendered.update(state)
        formViewController = FormViewController(sections: rendered.element, title: "Personal Hotspot Settings")
    }
}

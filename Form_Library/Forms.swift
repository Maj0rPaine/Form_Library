//
//  Forms.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

// MARK: - Table view controller

class Section {
    let cells: [FormCell]
    var footerTitle: String?
    
    init(cells: [FormCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
}

class FormViewController: UITableViewController {
    var sections: [Section] = []
    var firstResponder: UIResponder?
    
    func reloadSectionFooters() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        
        for index in sections.indices {
            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()
        }
        
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    init(sections: [Section], firstResponder: UIResponder? = nil, rightNavItems: [UIBarButtonItem]? = nil) {
        self.firstResponder = firstResponder
        self.sections = sections
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
}

// MARK: - Form driver

typealias Element<El, A> = (RenderingContext<A>) -> RenderedElement<El, A>
typealias Form<A> = Element<[Section], A>

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

func section<State>(_ cells: [Element<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil) -> Element<Section, State> {
    return { context in
        let renderedCells = cells.map { $0(context) }
        let strongReferences = renderedCells.flatMap { $0.strongReferences }
        let section = Section(cells: renderedCells.map { $0.element }, footerTitle: nil)
        let update: (State) -> () = { state in
            for c in renderedCells {
                c.update(state)
            }
            if let kp = keyPath {
                section.footerTitle = state[keyPath: kp]
            }
        }
        return RenderedElement(element: section, strongReferences: strongReferences, update: update)
    }
}

func sections<State>(_ sections: [Element<Section, State>]) -> Form<State> {
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

/// Generic form driver renders form context and observes changes.
class FormDriver<State> {
    var formViewController: FormViewController!
    var rendered: RenderedElement<[Section], State>!
    
    var state:State {
        didSet {
            dump(state)
            rendered.update(state)
            formViewController.reloadSectionFooters()
        }
    }
    
    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>) {
        self.state = state
        
        // Create rendering context with state, change and push functions
        let context = RenderingContext(
            state: state,
            change: { [unowned self] f in
                f(&self.state) // Mutate state
            }, pushViewController: { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: { [unowned self] in
                self.formViewController.navigationController?.popViewController(animated: true)
            })
        
        rendered = build(context)
        rendered.update(state)
        formViewController = FormViewController(sections: rendered.element)
    }
}

// MARK: - Components

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
        let nested = FormViewController(sections: rendered.element)
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

///// Bind parent form to nested child form
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

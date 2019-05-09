//
//  FormsViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 4/30/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

// MARK: - Cells

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
}

func controlCell<State>(control: @escaping Element<UIView, State>) -> Element<FormCell, State> {
    return { context in
        let renderedControl = control(context)
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.contentView.addSubview(renderedControl.element)
        cell.contentView.addConstraints([
            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            renderedControl.element.leadingAnchor.constraint(equalTo:  cell.contentView.layoutMarginsGuide.leadingAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        return FormElement(element: cell, strongReferences: renderedControl.strongReferences, update: renderedControl.update)
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


// MARK: - Sections

class TableSection {
    var cells: [FormCell]
    var footerTitle: String?
    var isVisible: Bool
    
    init(cells: [FormCell], footerTitle: String?, isVisible: Bool) {
        self.cells = cells
        self.footerTitle = footerTitle
        self.isVisible = isVisible
    }
}

extension TableSection: Equatable {
    static func ==(lhs: TableSection, rhs: TableSection) -> Bool {
        return lhs === rhs
    }
}

func renderedSection<State>(_ cells: [Element<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil, isVisible: KeyPath<State, Bool>? = nil) -> RenderedSection<State> {
    return { context in
        let renderedCells = cells.map { $0(context) }
        let strongReferences = renderedCells.flatMap { $0.strongReferences }
        let section = TableSection(cells: renderedCells.map { $0.element }, footerTitle: nil, isVisible: true)
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
        return FormElement(element: section, strongReferences: strongReferences, update: update)
    }
}

func renderedSections<State>(_ sections: [RenderedSection<State>]) -> Form<State> {
    return { context in
        let renderedSections = sections.map { $0(context) }
        let strongReferences = renderedSections.flatMap { $0.strongReferences }
        let update: (State) -> () = { state in
            for c in renderedSections {
                c.update(state)
            }
        }
        return FormElement(element: renderedSections.map { $0.element }, strongReferences: strongReferences, update: update)
    }
}

// MARK: - TVC

class FormViewController: UITableViewController {
    var firstResponder: UIResponder?
    
    var sections: [TableSection] = []
    
    var previouslyVisibleSections: [TableSection] = []
    
    var visibleSections: [TableSection] {
        return sections.filter { $0.isVisible }
    }
    
    init(sections: [TableSection], firstResponder: UIResponder? = nil) {
        super.init(style: .grouped)
        self.sections = sections
        previouslyVisibleSections = visibleSections
        self.firstResponder = firstResponder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].cells.count
    }
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return visibleSections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return visibleSections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
    func reloadSections() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let section = sections[index]
            let newIndex = visibleSections.index(of: section)
            let oldIndex = previouslyVisibleSections.index(of: section)
            
            switch (newIndex, oldIndex) {
            case (nil, nil), (.some, .some): break
            case let (newIndex?, nil):
                tableView.insertSections([newIndex], with: .automatic)
            case let (nil, oldIndex?):
                tableView.deleteSections([oldIndex], with: .automatic)
            }
            
            if let i = newIndex {
                let footer = tableView.footerView(forSection: i)
                footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: i)
                footer?.setNeedsLayout()
            }
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        previouslyVisibleSections = visibleSections
    }
}

extension UIViewController {
    func renderChildTableViewController(controller: UITableViewController) {
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        view.addConstraints([
            controller.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            controller.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        controller.didMove(toParentViewController: self)
    }
}

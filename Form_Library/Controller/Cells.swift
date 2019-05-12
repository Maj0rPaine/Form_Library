//
//  Cells.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

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


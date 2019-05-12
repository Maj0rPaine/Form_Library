//
//  Section.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

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

//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

/// Hotspot settings
struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

func section<State>(_ renderedCells: [RenderedElement<FormCell, State>]) -> RenderedElement<Section, State> {
    let cells = renderedCells.map { $0.element }
    let strongReferences = renderedCells.flatMap { $0.strongReferences }
    let update: (State) -> () = { state in
        for c in renderedCells {
            c.update(state)
        }
    }
    return RenderedElement(
        element: Section(cells: cells, footerTitle: nil),
        strongReferences: strongReferences,
        update: update
    )
}

func sections<State>(_ renderedSections: [RenderedElement<Section, State>]) -> RenderedElement<[Section], State> {
    let sections = renderedSections.map { $0.element }
    let strongReferences = renderedSections.flatMap { $0.strongReferences }
    let update: (State) -> () = { state in
        for c in renderedSections {
            c.update(state)
        }
    }
    return RenderedElement(element: sections, strongReferences: strongReferences, update: update)
}

/**
 Free function that builds form for settings.
 - Parameters:
    - context: RenderingContext struct
 - Returns: RenderElement struct
 */
func hotspotForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    let renderedToggle = uiSwitch(context: context, keyPath: \Hotspot.isEnabled)
    let renderedToggleCell = controlCell(title: "Personal Hotspot", control: renderedToggle)
    let toggleSection = section([renderedToggleCell])
    
    // Append function to update footer
//    updates.append { state in
//        toggleSection.footerTitle = state.enabledSectionTitle
//    }

    // Build nested password form
    let renderedPasswordForm = buildPasswordForm(context: context)
    let nested = FormViewController(sections: renderedPasswordForm.element, title: "Personal Hotspot Password")
    let passwordCell = detailTextCell(title: "Password", keyPath: \Hotspot.password) {
        context.pushViewController(nested)
    }
    
    let passwordSection = section([passwordCell])

    return sections([toggleSection, passwordSection])
}

/**
 Builds password form with one text field cell.
 - Parameters:
    - context: RenderingContext struct
 - Returns: RenderedElement struct
 */
func buildPasswordForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    let renderedPasswordField = uiTextField(context: context, keyPath: \Hotspot.password)
    let renderedCell = controlCell(title: "Password", control: renderedPasswordField, leftAligned: true)
    return sections([section([renderedCell])])
}

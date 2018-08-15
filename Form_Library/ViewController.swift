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

let hotspotForm: Form<Hotspot> = sections([
    section([
        controlCell(title: "Personal Hotspot", control: uiSwitch(keyPath: \Hotspot.isEnabled))
        ], footer: \Hotspot.enabledSectionTitle),
    section([
        detailTextCell(title: "Password", keyPath: \Hotspot.password, form: buildPasswordForm)
    ])
])

let buildPasswordForm: Form<Hotspot> = sections([
    section([controlCell(title: "Password", control: uiTextField(keyPath: \Hotspot.password), leftAligned: true)])
])

//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

enum ShowPreview {
    case always
    case never
    case whenUnlocked
    
    static let all: [ShowPreview] = [.always, .whenUnlocked, .never]
    
    var text: String {
        switch self {
        case .always: return "Always"
        case .whenUnlocked: return "When Unlocked"
        case .never: return "Never"
        }
    }
}

/// Hotspot settings
struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "myPassword"
    var networkName: String = "my network"
    var showPreview: ShowPreview = .always
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

let showPreviewForm: Form<Hotspot> = sections([
    section(
        ShowPreview.all.map { option in
            optionCell(title: option.text, option: option, keyPath: \.showPreview)
        }
    )
])

let hotspotForm: Form<Hotspot> = sections([
    section([
        controlCell(title: "Personal Hotspot", control: uiSwitch(keyPath: \.isEnabled))
    ], footer: \Hotspot.enabledSectionTitle),
    section([
        detailTextCell(title: "Notification", keyPath: \.showPreview.text, form: showPreviewForm)
    ]),
    section([
        nestedTextField(title: "Password", keyPath: \.password),
        nestedTextField(title: "Network Name", keyPath: \.networkName)
    ])
])

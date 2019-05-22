//
//  FormErrorLabel.swift
//  Form_Library
//
//  Created by Chris Paine on 5/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class FormErrorLabel: UILabel {
    override var text: String? {
        didSet {
            if let text = text {
                isHidden = text.isEmpty
            } else {
                isHidden = true
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 10, weight: .bold)
        textColor = .red
        numberOfLines = 0
    }
}

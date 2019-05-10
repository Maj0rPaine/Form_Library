//
//  Controls.swift
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

class FormField: UITextField, FormValidatable {
    var rules: [Rules] = []
    
    var inputState: FormValidatableState = .pristine {
        didSet {
            switch inputState {
            case .invalid(let message):
                errorLabel.text = message
                break
            default:
                errorLabel.text = nil
                break
            }
        }
    }
    
    var shouldValidate: Bool {
        return inputState.shouldValidate
    }
    
    override var text: String? {
        didSet {
            if let newText = text, !newText.isEmpty {
                inputState = .dirty
            }
        }
    }
    
    private var maskedListener: MaskedListener?
        
    private var errorLabel: FormErrorLabel = FormErrorLabel()
    
    convenience init(rules: [Rules], mask: String? = nil, notations: MaskedNotations? = nil, placeholder: String? = nil, keyboardType: UIKeyboardType = .default) {
        self.init()
        self.rules = rules
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(errorLabel)
        errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
        if let mask = mask {
            maskedListener = MaskedListener()
            delegate = maskedListener?.setMask(mask, notations: notations)
        }
    }

    func setErrorMessage(_ message: String) {
        inputState.message = message
    }
}

class FormPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var picker: UIPickerView = UIPickerView()
    
    var pickerData: [String]
    
    var textField: FormField!
    
    var didSelect: ((String) -> ())?
    
    lazy var selectedRow: Int = {
        return picker.selectedRow(inComponent: 0)
    }()
    
    init(with pickerData: [String], textField: FormField) {
        self.pickerData = pickerData
        self.textField = textField
        self.textField.inputView = picker
        super.init()
        self.picker.dataSource = self
        self.picker.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelect?(pickerData[row])
    }
}

extension FormPicker {
    func selectRow(row: Int?) {
        picker.selectRow(row ?? 0, inComponent: 0, animated: true)
    }
    
    func selectRow(value: String?) {
        guard let value = value else { return }
        picker.selectRow(pickerData.firstIndex(of: value) ?? 0, inComponent: 0, animated: true)
    }
}

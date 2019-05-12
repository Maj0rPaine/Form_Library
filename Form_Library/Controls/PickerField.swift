//
//  PickerField.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

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

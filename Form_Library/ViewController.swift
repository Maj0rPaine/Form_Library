//
//  ViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 4/29/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

struct PersonalInfo {
    var firstName: String = ""
    var lastName: String = ""
    var ssn: String = ""
    var birthdate: String = ""
    var phone: String = ""
    var address: Address = Address()
}

struct Address {
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
}

let firstNameField = FormField(rules: [.required], placeholder: "First Name")
let lastNameField = FormField(rules: [.required], placeholder: "Last Name")
let ssnField = FormField(rules: [.ssn], mask: MaskedFormat.ssnFormat, placeholder: "SSN", keyboardType: .decimalPad)
let dobField = FormField(rules: [.date], mask: MaskedFormat.dateFormat, placeholder: "Birthdate", keyboardType: .decimalPad)
let phoneField = FormField(rules: [.phone], mask: MaskedFormat.phoneFormat, placeholder: "Phone Number", keyboardType: .decimalPad)
let streetField = FormField(rules: [.required], placeholder: "Street")
let cityField = FormField(rules: [.required], placeholder: "City")
let stateField = FormPicker(with: ["A"], textField: FormField(rules: [.required], placeholder: "State"))
let zipField = FormField(rules: [.zip], placeholder: "Zip Code", keyboardType: .decimalPad)

// MARK: - Rendering view controller

let form: Form<PersonalInfo> =
    renderedSections([
        renderedSection([
            controlCell(control: formTextField(textField: firstNameField, keyPath: \.firstName)),
            controlCell(control: formTextField(textField: lastNameField, keyPath: \.lastName)),
            controlCell(control: formTextField(textField: ssnField, keyPath: \.ssn)),
            controlCell(control: formTextField(textField: dobField, keyPath: \.birthdate)),
            controlCell(control: formTextField(textField: phoneField, keyPath: \.phone)),
            ]),
        renderedSection([
            controlCell(control: formTextField(textField: streetField, keyPath: \.address.street)),
            controlCell(control: formTextField(textField: cityField, keyPath: \.address.city)),
            controlCell(control: formPickerField(formPicker: stateField, keyPath: \.address.state)),
            controlCell(control: formTextField(textField: zipField, keyPath: \.address.zip))
            ])
        ])


//let driver = TestFormDriver(initial: PersonalInfo(), build: form, title: "Test Form")
//
//class TestFormDriver<State>: FormDriver<State> {
//    override init(initial state: State, build: Element<[Any], State>, title: String) {
//        super.init(initial: state, build: build)
//
//        formViewController?.title = title
//
//        formViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveForm))
//    }
//
//    @objc func saveForm() {
//        dump(state)
//        formValidation.validate()
//    }
//}

// MARK: - Rendering view controller

class RenderingController: UIViewController {
    var driver: FormDriver<PersonalInfo>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        driver = FormDriver(
            initial: PersonalInfo(),
            build: renderedSections([
                renderedSection([
                    controlCell(control: formTextField(textField: firstNameField, keyPath: \.firstName)),
                    controlCell(control: formTextField(textField: lastNameField, keyPath: \.lastName)),
                    controlCell(control: formTextField(textField: ssnField, keyPath: \.ssn)),
                    controlCell(control: formTextField(textField: dobField, keyPath: \.birthdate)),
                    controlCell(control: formTextField(textField: phoneField, keyPath: \.phone)),
                    ]),
                renderedSection([
                    controlCell(control: formTextField(textField: streetField, keyPath: \.address.street)),
                    controlCell(control: formTextField(textField: cityField, keyPath: \.address.city)),
                    controlCell(control: formPickerField(formPicker: stateField, keyPath: \.address.state)),
                    controlCell(control: formTextField(textField: zipField, keyPath: \.address.zip))
                    ])
                ]),
            title: "Test Form",
            presentingController: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveForm))
    }
    
    @objc func saveForm() {
        dump(driver.state)
        driver.validateForm { (errors) in
            if let errors = errors {
                print(errors)
            }
        }
    }
}

// MARK: - Non rendering view controller

class NonRenderingController: UIViewController {
    var driver: FormDriver<PersonalInfo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackview = UIStackView(arrangedSubviews: [firstNameField, lastNameField, ssnField, dobField, phoneField, streetField, cityField, stateField.textField, zipField])
        stackview.axis = .vertical
        stackview.spacing = 5.0
        stackview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackview)
        stackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stackview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        driver = FormDriver(
            initial: PersonalInfo(),
            build: section([
                formTextField(textField: firstNameField, keyPath: \.firstName),
                formTextField(textField: lastNameField, keyPath: \.lastName),
                formTextField(textField: ssnField, keyPath: \.ssn),
                formTextField(textField: dobField, keyPath: \.birthdate),
                formTextField(textField: phoneField, keyPath: \.phone),
                formTextField(textField: streetField, keyPath: \.address.street),
                formTextField(textField: cityField, keyPath: \.address.city),
                formPickerField(formPicker: stateField, keyPath: \.address.state),
                formTextField(textField: zipField, keyPath: \.address.zip)
                ]))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveForm))
    }
    
    @objc func saveForm() {
        dump(driver.state)
        //driver.formValidation.validate()
    }
}

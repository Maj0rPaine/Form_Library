//
//  ControlsTests.swift
//  Form_LibraryTests
//
//  Created by Chris Paine on 5/22/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import XCTest
import InputMask
@testable import Form_Library

class FormErrorLabelTests: XCTestCase {
    var label: FormErrorLabel!

    override func setUp() {
        label = FormErrorLabel()
        label.text = "Error"
    }

    override func tearDown() {
        label = nil
    }
    
    func testShowErrorLabel() {
        XCTAssertFalse(label.isHidden)
    }
    
    func testHideErrorLabel() {
        XCTAssertFalse(label.isHidden)
        label.text = nil
        XCTAssertTrue(label.isHidden)
    }
    
    func testHideErrorLabelWithString() {
        XCTAssertFalse(label.isHidden)
        label.text = ""
        XCTAssertTrue(label.isHidden)
    }
}

class FormFieldTests: XCTestCase {
    var field: FormField!
    
    override func setUp() {
        field = FormField(rules: [.required])
    }
    
    override func tearDown() {
        field = nil
    }
    
    func testInit() {
        XCTAssertFalse(field.rules.isEmpty)
        XCTAssertFalse(field.subviews.filter {$0 is FormErrorLabel}.isEmpty)
    }
    
    func testPristineState() {
        XCTAssertTrue(field.inputState == .pristine)
        field.text = ""
        XCTAssertTrue(field.inputState == .pristine)
    }
    
    func testDirtyState() {
        field.text = "Test"
        XCTAssertTrue(field.inputState == .dirty)
    }
    
    func testShouldValidateTrue() {
        field.text = "Test"
        XCTAssertTrue(field.shouldValidate)
    }
    
    func testShouldValidateFalse() {
        XCTAssertFalse(field.shouldValidate)
        field.text = ""
        XCTAssertFalse(field.shouldValidate)
    }
    
    func testSetErrorMessage() {
        field.setErrorMessage("Error")
        let errorLabel = field.subviews.first { $0 is FormErrorLabel}
        XCTAssertEqual((errorLabel as! FormErrorLabel).text, "Error")
    }
    
    func testSetErrorMessageEmpty() {
        field.setErrorMessage("")
        let errorLabel = field.subviews.first { $0 is FormErrorLabel}
        XCTAssertNil((errorLabel as! FormErrorLabel).text)
    }
    
    func testNotValidTrue() {
        field.setErrorMessage("Error")
        XCTAssertTrue(field.notValid)
    }
    
    func testNotValidFalse() {
        XCTAssertFalse(field.notValid)
    }
}

class MaskedFieldTests: XCTestCase {
    func testPhoneNumberMasking() {
        let number = "1234567890"
        let formatted = number.applyMask(mask: MaskedFormat.phone)
        XCTAssertEqual(formatted, "123-456-7890")
    }
    
    func testSSNMasking() {
        let ssn = "123456789"
        let formatted = ssn.applyMask(mask: MaskedFormat.ssn)
        XCTAssertEqual(formatted, "123-45-6789")
    }
}

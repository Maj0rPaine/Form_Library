//
//  ValidationTests.swift
//  ValidationTests
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import XCTest
@testable import Form_Library

class ValidationTests: XCTestCase {
    var formValidation: FormValidation!
    
    var expectation: XCTestExpectation!
    
    let field = FormField(rules: [.required])
    
    override func setUp() {
        super.setUp()
        
        formValidation = FormValidation()
        formValidation.observe(field)
        field.inputState = .pristine
    }
    
    override func tearDown() {
        formValidation.unobserve(field)
        formValidation = nil
        
        super.tearDown()
    }
    
    func testRegisteredFieldsEmpty() {
        formValidation.unobserve(field)
        XCTAssertTrue(formValidation.registeredFields.isEmpty)
    }
    
    func testRegisteredFieldsNotEmpty() {
        XCTAssertFalse(formValidation.registeredFields.isEmpty)
    }
    
    func testRegisteredFieldsHasErrorsTrue() {
        field.inputState = .invalid(message: "")
        XCTAssertTrue(formValidation.hasErrors)
    }
    
    func testRegisteredFieldsHasErrorsFalse() {
        XCTAssertFalse(formValidation.hasErrors)
    }
    
    func testValidateForm() {
        expectation = expectation(description: "Validate form")
        field.text = "Test"
        formValidation.validateForm { (errors) in
            XCTAssertNil(errors)
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testValidateFormWithErrors() {
        expectation = expectation(description: "Validate form with errors")
        field.text = ""
        formValidation.validateForm { (errors) in
            XCTAssertNotNil(errors)
            XCTAssertEqual(errors?.first, "This field is required")
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testIsValidClosureTruthy() {
        expectation = expectation(description: "Truthy isValid")
        field.text = "Test"
        formValidation.isValid = { valid in
            XCTAssertTrue(valid)
            self.expectation.fulfill()
        }
        formValidation.validateField(field)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testIsValidClosureFalsy() {
        expectation = expectation(description: "Falsy isValid")
        formValidation.isValid = { valid in
            XCTAssertFalse(valid)
            self.expectation.fulfill()
        }
        formValidation.validateField(field)
        waitForExpectations(timeout: 3, handler: nil)
    }
}

// MARK: - Validatables

class ValidatableTests: XCTestCase {
    var state: ValidatableState!
    
    override func setUp() {
        super.setUp()
        state = .pristine
    }
    
    func testStateTypes() {
        XCTAssertNotNil(ValidatableState.pristine)
        XCTAssertNotNil(ValidatableState.dirty)
        XCTAssertNotNil(ValidatableState.valid)
        XCTAssertNotNil(ValidatableState.invalid(message: ""))
    }
    
    func testMessage() {
        state = ValidatableState.invalid(message: "Error")
        XCTAssertEqual(state.message, "Error")
    }
    
    func testEmptyMessage() {
        XCTAssertTrue(state.message.isEmpty)
    }
    
    func testSetMessage() {
        state.message = "Error"
        XCTAssertEqual(state, .invalid(message: "Error"))
    }
    
    func testSetEmptyMessage() {
        state.message = ""
        XCTAssertEqual(state, .valid)
    }
    
    func testShouldValidate() {
        state = ValidatableState.dirty
        XCTAssertTrue(state.shouldValidate)
    }
    
    func testShouldNotValidate() {
        XCTAssertFalse(state.shouldValidate)
    }
    
    func testValid() {
        state = ValidatableState.valid
        XCTAssertFalse(state.notValid)
    }
    
    func testNotValid() {
        state = ValidatableState.invalid(message: "")
        XCTAssertTrue(state.notValid)
    }
}

// MARK: - Rules

class RulesTests: XCTestCase {
    func testValidPasswordRule() {
        XCTAssertTrue(PasswordRule().validate("Password1!"))
        XCTAssertTrue(PasswordRule().validate("passWord1!"))
        XCTAssertTrue(PasswordRule().validate("Password123!@#"))
    }
    
    func testInvalidPasswordRule() {
        XCTAssertFalse(PasswordRule().validate("password1"))
        XCTAssertFalse(PasswordRule().validate("password1!"))
        XCTAssertFalse(PasswordRule().validate("Password1"))
    }
    
    func testValidDateRule() {
        XCTAssertTrue(DateRule().validate("02/15/2018"))
        XCTAssertTrue(DateRule().validate("02/15/1918"))
    }
    
    func testInvalidDateRule() {
        XCTAssertFalse(DateRule().validate("22/15/2018"))
        XCTAssertFalse(DateRule().validate("02/32/2018"))
        XCTAssertFalse(DateRule().validate("02/15/1818"))
    }
    
    func testValidSSNRule() {
        XCTAssertTrue(SSNRule().validate("400-11-2222"))
    }
    
    func testInvalidSSNRule() {
        XCTAssertFalse(SSNRule().validate("400112222"))
    }
    
    func testValidPhoneRule() {
        XCTAssertTrue(PhoneRule().validate("404-123-4567"))
    }
    
    func testInvalidPhoneRule() {
        XCTAssertFalse(PhoneRule().validate("4041234567"))
    }
}

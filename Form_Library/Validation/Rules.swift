//
//  Rules.swift
//  Form_Library
//
//  Created by Chris Paine on 5/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import SwiftValidator

class PasswordRule: RegexRule {
    // Minimum 1 uppercase, special, numeric, and at least 8 characters
    static let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$!%^*?&])[A-Za-z0-9@#$^!%*?&]{8,}$"
    convenience init(message: String = "Not a valid password") {
        self.init(regex: PasswordRule.regex, message: message)
    }
}

class DateRule: RegexRule {
    // Covers 1900 and 2000 centuries
    static let regex = "^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$"
    convenience init(message: String = "Not a valid date") {
        self.init(regex: DateRule.regex, message: message)
    }
}

class SSNRule: RegexRule {
    static let regex = "^\\d{3}-\\d{2}-\\d{4}$"
    convenience init(message : String = "Not a valid SSN"){
        self.init(regex: SSNRule.regex, message : message)
    }
}

class PhoneRule: RegexRule {
    static let regex = "^\\d{3}-\\d{3}-\\d{4}$"
    convenience init(message : String = "Not a valid phone number"){
        self.init(regex: PhoneRule.regex, message : message)
    }
}

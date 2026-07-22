//
//  LoginViewModelTests.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 14/07/26.
//

// LoginViewModelTests.swift
// Tests for login form validation logic
// Ensures the login button only enables when input is actually valid

import Testing
@testable import Meridian

@Suite("LoginViewModel Tests")
@MainActor
struct LoginViewModelTests {
    
    // Test — empty email and password means form is invalid
    @Test("Empty fields make form invalid")
    func testEmptyFieldsInvalid() {
        let viewModel = LoginViewModel()
        viewModel.email = ""
        viewModel.password = ""
        
        #expect(viewModel.isFormValid == false)
    }
    
    // Test — only email filled, password empty, still invalid
    @Test("Only email filled is still invalid")
    func testOnlyEmailInvalid() {
        let viewModel = LoginViewModel()
        viewModel.email = "test@test.com"
        viewModel.password = ""
        
        #expect(viewModel.isFormValid == false)
    }
    
    // Test — only password filled, email empty, still invalid
    @Test("Only password filled is still invalid")
    func testOnlyPasswordInvalid() {
        let viewModel = LoginViewModel()
        viewModel.email = ""
        viewModel.password = "password123"
        
        #expect(viewModel.isFormValid == false)
    }
    
    // Test — both fields filled with valid content means form is valid
    @Test("Both fields filled makes form valid")
    func testBothFieldsValid() {
        let viewModel = LoginViewModel()
        viewModel.email = "test@test.com"
        viewModel.password = "password123"
        
        #expect(viewModel.isFormValid == true)
    }
    
    // Test — whitespace-only email should still count as invalid
    // Catches a subtle bug — a user accidentally typing just spaces
    // shouldn't be treated as a valid email
    @Test("Whitespace-only email is invalid")
    func testWhitespaceEmailInvalid() {
        let viewModel = LoginViewModel()
        viewModel.email = "   "
        viewModel.password = "password123"
        
        #expect(viewModel.isFormValid == false)
    }
}

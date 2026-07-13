//
//  LoginViewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 07/06/26.
//

import Foundation
import Observation

@Observable
class LoginViewModel {

    var email = ""
    var password = ""

    var isPasswordVisible = false
    var isLoading = false
    var errorMessage: String?

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func login() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        await AuthManager.shared.login(
            email: email.trimmingCharacters(in: .whitespaces),
            password: password
        )

        if let error = AuthManager.shared.errorMessage {
            errorMessage = error
        }
    }
}

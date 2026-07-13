//
//  RegisterVIewModel.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 12/06/26.
//

import Foundation
import Observation

@Observable
class RegisterViewModel {

    var fullName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    var selectedRole: UserRole = .student

    var isPasswordVisible = false
    var isConfirmPasswordVisible = false

    var isLoading = false
    var errorMessage: String?

    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }

    var passwordsMatch: Bool {
        password == confirmPassword
    }

    func register() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        await AuthManager.shared.register(
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            password: password,
            role: selectedRole.rawValue
        )

        if let error = AuthManager.shared.errorMessage {
            errorMessage = error
        }
    }
}

enum UserRole: String, CaseIterable {
    case student = "student"
    case professor = "professor"

    var displayName: String {
        switch self {
        case .student:
            return "Student"
        case .professor:
            return "Professor"
        }
    }

    var icon: String {
        switch self {
        case .student:
            return "graduationcap.fill"
        case .professor:
            return "person.fill.checkmark"
        }
    }
}

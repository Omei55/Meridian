
//
//  User.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 07/06/26.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let fullName: String
    let email: String
    let role: String

    var isProfessor: Bool {
        role == "professor"
    }
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

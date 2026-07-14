//
//  AuthManager.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 07/06/26.
//

import Foundation
import Observation
import FirebaseAuth

@Observable
class AuthManager {

    static let shared = AuthManager()

    var currentUser: User?
    var errorMessage: String?
    var isLoading = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    var isProfessor: Bool {
        currentUser?.isProfessor ?? false
    }

    private init() {
        if KeychainManager.shared.isLoggedIn {
            // Decode the token to check expiry
            // without making a network call
            if let token = KeychainManager.shared.getToken(),
               !isTokenExpired(token) {
                // Token is valid — we'll load user data
                // For now just mark as logged in
            } else {
                // Token expired — clear it
                logout()
            }
        }
    }

    // Check if JWT is expired by decoding the payload
    // JWT payload is base64 encoded — no library needed
    private func isTokenExpired(_ token: String) -> Bool {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return true }
        
        // Base64 decode the payload (second part)
        var base64 = parts[1]
        // Add padding if needed — base64 requires length divisible by 4
        while base64.count % 4 != 0 { base64 += "=" }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }
        
        // Compare expiry timestamp with current time
        return Date().timeIntervalSince1970 > exp
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let response: AuthResponse = try await APIClient.shared.request(
                endpoint: "/auth/login",
                method: "POST",
                body: [
                    "email": email,
                    "password": password
                ]
            )

            KeychainManager.shared.saveToken(response.accessToken)
            KeychainManager.shared.saveRefreshToken(response.refreshToken)
            currentUser = response.user
            MessagingState.shared.startListening(userId: response.user.id)

            // Sign in to Firebase
            await signInToFirebase()
            MessagingState.shared.startListening(userId: response.user.id)
            

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(
        fullName: String,
        email: String,
        password: String,
        role: String
    ) async {

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let response: AuthResponse = try await APIClient.shared.request(
                endpoint: "/auth/register",
                method: "POST",
                body: [
                    "fullName": fullName,
                    "email": email,
                    "password": password,
                    "role": role
                ]
            )

            KeychainManager.shared.saveToken(response.accessToken)
            KeychainManager.shared.saveRefreshToken(response.refreshToken)
            currentUser = response.user
            MessagingState.shared.startListening(userId: response.user.id)
            
            await signInToFirebase()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        // Notify backend to invalidate the refresh token
        // Fire and forget — we don't need to wait for this
        if let refreshToken = KeychainManager.shared.getRefreshToken() {
            Task {
                let _: [String: Bool]? = try? await APIClient.shared.request(
                    endpoint: "/auth/logout",
                    method: "POST",
                    body: ["refreshToken": refreshToken]
                )
            }
        }
        
        KeychainManager.shared.deleteToken()
        KeychainManager.shared.deleteRefreshToken()
        currentUser = nil
        errorMessage = nil
    }
    func signInToFirebase() async {
        do {
            try await Auth.auth().signInAnonymously()
            print("Firebase anonymous auth successful")
        } catch {
            print("Firebase auth error: \(error.localizedDescription)")
        }
    }
    
}

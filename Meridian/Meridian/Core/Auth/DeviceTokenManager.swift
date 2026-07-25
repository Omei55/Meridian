//
//  DeviceTokenManager.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 25/07/26.
//

// DeviceTokenManager.swift
// Sends the FCM device token to our backend
// Backend stores it in PostgreSQL so it knows where to send pushes later

import Foundation

class DeviceTokenManager {
    
    static let shared = DeviceTokenManager()
    
    private init() {}
    
    // Sends the FCM token to our backend
    // Called whenever Firebase generates or refreshes the token
    func saveTokenToBackend(_ token: String) async {
        // Only send if user is logged in
        // Token registration only makes sense for authenticated users
        guard KeychainManager.shared.getToken() != nil else {
            print("No auth token yet — skipping device token registration")
            return
        }
        
        do {
            struct DeviceTokenResponse: Codable {
                let success: Bool
            }
            
            let _: DeviceTokenResponse = try await APIClient.shared.request(
                endpoint: "/users/device-token",
                method: "POST",
                body: ["deviceToken": token]
            )
            
            print("Device token registered successfully")
            
        } catch {
            print("Failed to register device token: \(error)")
        }
    }
}

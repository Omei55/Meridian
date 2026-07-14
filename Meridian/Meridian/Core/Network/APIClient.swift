//
//  APIClient.swift
//  Meridian
//
//  Created by Omkar Vilas Sapkal on 07/06/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case serverError(String)
    case unauthorized
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .serverError(let msg):
            return msg
        case .unauthorized:
            return "Please log in again"
        case .decodingError:
            return "Failed to read server response"
        }
    }
}

class APIClient {

    static let shared = APIClient()

    private let baseURL = "https://meridian-api-production-3bb7.up.railway.app"

    private init() {}

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        if let token = KeychainManager.shared.getToken() {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: body
            )
        }

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        if httpResponse.statusCode == 401 {
            // Access token expired — try to silently refresh
            if let newAccessToken = await refreshAccessToken() {
                // Retry the original request with the new token
                var retryRequest = request
                retryRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                
                let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
                
                guard let retryHttpResponse = retryResponse as? HTTPURLResponse,
                      (200...299).contains(retryHttpResponse.statusCode) else {
                    // Even after refresh, request failed — truly log out
                    await MainActor.run { AuthManager.shared.logout() }
                    throw APIError.unauthorized
                }
                
                // Decode and return the retried response
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: retryData)
                
            } else {
                // Refresh token also invalid/expired — must log in again
                await MainActor.run { AuthManager.shared.logout() }
                throw APIError.unauthorized
            }
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorBody = try? JSONDecoder().decode(
                [String: String].self,
                from: data
            ),
               let message = errorBody["error"] {
                throw APIError.serverError(message)
            }

            throw APIError.serverError("Something went wrong")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
        
    
    }
    // Attempts to get a new access token using the stored refresh token
    // Returns nil if refresh token is missing or invalid
    private func refreshAccessToken() async -> String? {
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            return nil
        }
        
        guard let url = URL(string: baseURL + "/auth/refresh") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            struct RefreshResponse: Codable {
                let accessToken: String
            }
            
            let decoded = try JSONDecoder().decode(RefreshResponse.self, from: data)
            
            // Save the new access token
            KeychainManager.shared.saveToken(decoded.accessToken)
            
            return decoded.accessToken
            
        } catch {
            return nil
        }
    }
}



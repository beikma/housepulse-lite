import Foundation
import AuthenticationServices

class SupabaseService {
    static let shared = SupabaseService()

    private let url: String
    private let anonKey: String
    private var accessToken: String?

    private init() {
        self.url = SupabaseConfig.url
        self.anonKey = SupabaseConfig.anonKey
    }

    // MARK: - Authentication

    func signInWithApple(identityToken: String, nonce: String) async throws -> User {
        let endpoint = "\(url)/auth/v1/token?grant_type=id_token"

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: Any] = [
            "provider": "apple",
            "id_token": identityToken,
            "nonce": nonce
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SupabaseError.authenticationFailed
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = authResponse.accessToken

        return authResponse.user
    }

    func signInWithEmail(email: String, password: String) async throws -> User {
        let endpoint = "\(url)/auth/v1/token?grant_type=password"

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SupabaseError.authenticationFailed
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = authResponse.accessToken

        return authResponse.user
    }

    func signOut() {
        accessToken = nil
    }

    // MARK: - Edge Functions

    func pairHome(homeId: String, mcpApiKey: String) async throws -> PairHomeResponse {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }

        let endpoint = "\(SupabaseConfig.functionsURL)/pair_home"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body = PairHomeRequest(homeId: homeId, mcpApiKey: mcpApiKey)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(PairHomeResponse.self, from: data)
        } else {
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw SupabaseError.apiError(error?.error ?? "Unknown error")
        }
    }

    func systemCheck(homeId: String) async throws -> SystemCheckResponse {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }

        let endpoint = "\(SupabaseConfig.functionsURL)/system_check"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body = SystemCheckRequest(homeId: homeId)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(SystemCheckResponse.self, from: data)
        } else {
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw SupabaseError.apiError(error?.error ?? "Unknown error")
        }
    }
}

// MARK: - Supporting Types

struct AuthResponse: Codable {
    let accessToken: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

enum SupabaseError: LocalizedError {
    case authenticationFailed
    case notAuthenticated
    case networkError
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .notAuthenticated:
            return "Not authenticated. Please sign in."
        case .networkError:
            return "Network error. Please check your connection."
        case .apiError(let message):
            return message
        }
    }
}

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedHome: Home?
    @Published var mcpApiKey: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPaired = false
    @Published var systemCheckResponse: SystemCheckResponse?

    private let supabaseService = SupabaseService.shared
    private let keychainService = KeychainService.shared

    // Step 1: Select home (mock data)
    let availableHomes = Home.mockHomes

    // Step 2: Pair home with MCP API key
    func pairHome() async {
        guard let home = selectedHome else {
            errorMessage = "Please select a home"
            return
        }

        guard !mcpApiKey.isEmpty else {
            errorMessage = "Please enter your MCP API key"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Call pair_home edge function
            let response = try await supabaseService.pairHome(
                homeId: home.id.uuidString,
                mcpApiKey: mcpApiKey
            )

            if response.paired {
                // Store API key securely in Keychain
                let saved = keychainService.saveMCPApiKey(
                    mcpApiKey,
                    for: home.id.uuidString
                )

                if !saved {
                    throw SupabaseError.apiError("Failed to save API key securely")
                }

                // Verify pairing with system_check
                try await performSystemCheck()
            } else {
                errorMessage = "Pairing failed. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Step 3: Verify system with system_check
    func performSystemCheck() async throws {
        guard let home = selectedHome else {
            throw SupabaseError.apiError("No home selected")
        }

        let response = try await supabaseService.systemCheck(
            homeId: home.id.uuidString
        )

        if response.ok {
            systemCheckResponse = response
            isPaired = true
        } else {
            throw SupabaseError.apiError("System check failed")
        }
    }

    // Retry pairing flow
    func retry() {
        errorMessage = nil
        systemCheckResponse = nil
    }

    // Reset onboarding
    func reset() {
        selectedHome = nil
        mcpApiKey = ""
        errorMessage = nil
        isPaired = false
        systemCheckResponse = nil
    }
}

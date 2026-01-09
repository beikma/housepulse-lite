import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showRateLimitHint: Bool = false
    @Published var dailyMessageCount: Int = 0

    private let supabaseService = SupabaseService.shared
    private var homeId: String
    private let locale = "de-DE"
    private let freeMessageLimit = 50

    init(homeId: String) {
        self.homeId = homeId
        loadDailyCount()
    }

    // Send message to chat API
    func sendMessage(_ text: String? = nil) async {
        let messageText = text ?? currentInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !messageText.isEmpty else { return }

        // Clear input immediately
        currentInput = ""

        // Add user message to UI
        let userMessage = ChatMessage(role: "user", content: messageText)
        messages.append(userMessage)

        // Set loading state
        isLoading = true
        errorMessage = nil
        showRateLimitHint = false

        do {
            // Call chat API
            let response = try await supabaseService.chat(
                homeId: homeId,
                locale: locale,
                messages: messages
            )

            // Add assistant response
            let assistantMessage = ChatMessage(
                role: "assistant",
                content: response.reply,
                toolEvents: response.toolEvents
            )
            messages.append(assistantMessage)

            // Increment daily count (UX only, server is source of truth)
            incrementDailyCount()

        } catch SupabaseError.rateLimitExceeded {
            // Show rate limit hint
            showRateLimitHint = true
            errorMessage = "Tageslimit erreicht (50 Nachrichten). Upgrade für unbegrenzte Nachrichten."

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Quick action chips
    func sendQuickAction(_ action: QuickAction) async {
        await sendMessage(action.prompt)
    }

    // Clear error
    func clearError() {
        errorMessage = nil
        showRateLimitHint = false
    }

    // Daily counter management (client-side UX only)
    private func loadDailyCount() {
        let today = getToday()
        let savedDate = UserDefaults.standard.string(forKey: "lastMessageDate") ?? ""
        let savedCount = UserDefaults.standard.integer(forKey: "dailyMessageCount")

        if savedDate == today {
            dailyMessageCount = savedCount
        } else {
            dailyMessageCount = 0
            UserDefaults.standard.set(today, forKey: "lastMessageDate")
            UserDefaults.standard.set(0, forKey: "dailyMessageCount")
        }
    }

    private func incrementDailyCount() {
        dailyMessageCount += 1
        UserDefaults.standard.set(dailyMessageCount, forKey: "dailyMessageCount")
    }

    private func getToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var remainingMessages: Int {
        return max(0, freeMessageLimit - dailyMessageCount)
    }

    var usageText: String {
        return "\(dailyMessageCount)/\(freeMessageLimit) heute"
    }
}

// MARK: - Quick Actions

enum QuickAction: String, CaseIterable {
    case statusCheck = "Status-Check"
    case risksWarning = "Risiken / Wartung"
    case energySaving = "Energie sparen"
    case escoCompliance = "ESCO-Compliance prüfen"

    var prompt: String {
        switch self {
        case .statusCheck:
            return "Zeige mir den aktuellen Status meines Hauses"
        case .risksWarning:
            return "Gibt es Wartungsprobleme oder Risiken?"
        case .energySaving:
            return "Wie kann ich Energie sparen?"
        case .escoCompliance:
            return "Prüfe die ESCO-Compliance"
        }
    }

    var icon: String {
        switch self {
        case .statusCheck:
            return "checkmark.circle.fill"
        case .risksWarning:
            return "exclamationmark.triangle.fill"
        case .energySaving:
            return "leaf.fill"
        case .escoCompliance:
            return "doc.text.magnifyingglass"
        }
    }
}

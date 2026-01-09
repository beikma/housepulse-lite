import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date
    let toolEvents: [ToolEvent]?

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date(), toolEvents: [ToolEvent]? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.toolEvents = toolEvents
    }

    var isUser: Bool {
        return role == "user"
    }
}

struct ToolEvent: Codable, Identifiable {
    var id: String { tool }
    let tool: String
    let status: String
}

// MARK: - API Models for Chat

struct ChatRequest: Codable {
    let homeId: String
    let locale: String
    let messages: [MessagePayload]

    enum CodingKeys: String, CodingKey {
        case homeId = "home_id"
        case locale
        case messages
    }

    struct MessagePayload: Codable {
        let role: String
        let content: String
    }
}

struct ChatResponse: Codable {
    let reply: String
    let toolEvents: [ToolEvent]?

    enum CodingKeys: String, CodingKey {
        case reply
        case toolEvents = "tool_events"
    }
}

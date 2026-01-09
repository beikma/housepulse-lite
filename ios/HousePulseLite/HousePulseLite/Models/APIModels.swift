import Foundation

// MARK: - Pair Home
struct PairHomeRequest: Codable {
    let homeId: String
    let mcpApiKey: String

    enum CodingKeys: String, CodingKey {
        case homeId = "home_id"
        case mcpApiKey = "mcp_api_key"
    }
}

struct PairHomeResponse: Codable {
    let paired: Bool
}

// MARK: - System Check
struct SystemCheckRequest: Codable {
    let homeId: String

    enum CodingKeys: String, CodingKey {
        case homeId = "home_id"
    }
}

struct SystemCheckResponse: Codable {
    let ok: Bool
    let lastDataTs: String
    let notes: [String]

    enum CodingKeys: String, CodingKey {
        case ok
        case lastDataTs = "last_data_ts"
        case notes
    }
}

// MARK: - Error Response
struct APIError: Codable {
    let error: String
}

import Foundation

struct User: Codable {
    let id: String
    let email: String?
    let appMetadata: [String: AnyCodable]?
    let userMetadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case appMetadata = "app_metadata"
        case userMetadata = "user_metadata"
    }
}

// Helper for dynamic JSON
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let int = value as? Int {
            try container.encode(int)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let double = value as? Double {
            try container.encode(double)
        }
    }
}

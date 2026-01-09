import Foundation

struct Home: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String?

    init(id: UUID = UUID(), name: String, address: String? = nil) {
        self.id = id
        self.name = name
        self.address = address
    }
}

extension Home {
    // Mock homes for MVP
    static let mockHomes: [Home] = [
        Home(name: "My Home", address: "123 Main St"),
        Home(name: "Vacation House", address: "456 Beach Rd"),
        Home(name: "Apartment", address: "789 City Ave")
    ]
}

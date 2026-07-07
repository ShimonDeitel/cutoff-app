import Foundation

struct CaffeineEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var drink: String
    var mg: Int
    var time: Date

    init(id: UUID = UUID(), createdAt: Date = Date(), drink: String = "", mg: Int = 0, time: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
        self.drink = drink
        self.mg = mg
        self.time = time
    }
}

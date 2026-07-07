import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [CaffeineEntry] = []
    @Published var settings: AppSettings = AppSettings()

    static let freeLimit = 30

    private let fileURL: URL
    private let settingsURL: URL

    init() {
        let dir = Store.appSupportDirectory()
        fileURL = dir.appendingPathComponent("cutoff_items.json")
        settingsURL = dir.appendingPathComponent("cutoff_settings.json")
        load()
        if items.isEmpty {
            seed()
        }
    }

    static func appSupportDirectory() -> URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([CaffeineEntry].self, from: data) {
            items = decoded
        }
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL)
        }
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
    }

    func seed() {
        items = Store.seedData()
        save()
    }

    static func seedData() -> [CaffeineEntry] {
        (0..<3).map { _ in CaffeineEntry() }
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: CaffeineEntry, isPro: Bool) -> Bool {
        guard canAdd(isPro: isPro) else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: CaffeineEntry) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }
}

struct AppSettings: Codable, Equatable {
    var remindersEnabled: Bool = true
    var soundEnabled: Bool = true
}

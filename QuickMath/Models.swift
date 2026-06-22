import SwiftUI
import SwiftData

// MARK: - SwiftData models

@Model
final class GratEntry {
    var id: UUID
    var date: Date
    var text: String
    var promptUsed: String?
    var favorite: Bool

    init(id: UUID = UUID(), date: Date = Date(), text: String, promptUsed: String? = nil, favorite: Bool = false) {
        self.id = id
        self.date = date
        self.text = text
        self.promptUsed = promptUsed
        self.favorite = favorite
    }
}

@Model
final class GratPrompt {
    var id: UUID
    var text: String
    var isPro: Bool

    init(id: UUID = UUID(), text: String, isPro: Bool = false) {
        self.id = id
        self.text = text
        self.isPro = isPro
    }
}

// MARK: - AppModel

@MainActor
final class AppModel: ObservableObject {
    let container: ModelContainer
    weak var store: Store?

    @Published private(set) var entries: [GratEntry] = []
    @Published private(set) var todayEntry: GratEntry? = nil
    @Published private(set) var streak: Int = 0
    @Published private(set) var todayPrompt: String = ""

    // Built-in prompt list (seeded once)
    static let builtInPrompts: [String] = [
        "What made you smile today?",
        "Name one person you're thankful for.",
        "What small comfort are you grateful for?",
        "What went better than expected today?",
        "What is something beautiful you noticed?",
        "What is a simple pleasure in your day?",
        "Who showed you kindness recently?",
        "What skill are you grateful to have?",
        "What ordinary thing do you appreciate?",
        "What made today unique?",
        "What challenge helped you grow?",
        "What food or drink brought you joy?",
        "What place are you grateful to live near?",
        "What memory made you feel warm today?",
        "What opportunity are you thankful for?",
        "Who supported you recently?",
        "What made you feel proud today?",
        "What technology simplified your life?",
        "What natural thing did you appreciate?",
        "What are you looking forward to?",
        "What habit improved your day?",
        "What did you learn that you're glad to know?",
        "What conversation energized you?",
        "What moment of quiet did you enjoy?",
        "What made your home feel comfortable?",
        "What act of generosity touched you?",
        "What creative thing did you appreciate?",
        "What did your body do well today?",
        "What problem did you solve today?",
        "What simple joy is in your life right now?"
    ]

    init(container: ModelContainer) {
        self.container = container
        reload()
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema([GratEntry.self, GratPrompt.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }

    func reload() {
        let ctx = container.mainContext
        let allEntries = (try? ctx.fetch(FetchDescriptor<GratEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
        entries = allEntries

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        todayEntry = allEntries.first { cal.startOfDay(for: $0.date) == today }

        // Compute streak
        var s = 0
        var checkDay = today
        for _ in 0..<365 {
            if allEntries.contains(where: { cal.startOfDay(for: $0.date) == checkDay }) {
                s += 1
                checkDay = cal.date(byAdding: .day, value: -1, to: checkDay)!
            } else {
                break
            }
        }
        streak = s

        // Pick today's prompt deterministically from date seed
        let dayIndex = Int(today.timeIntervalSince1970 / 86400) % Self.builtInPrompts.count
        todayPrompt = Self.builtInPrompts[dayIndex]
    }

    func refresh() { reload() }

    func saveEntry(text: String, promptUsed: String?) {
        let ctx = container.mainContext

        // Remove existing today entry if any
        if let existing = todayEntry {
            ctx.delete(existing)
        }

        let entry = GratEntry(date: Date(), text: text, promptUsed: promptUsed, favorite: false)
        ctx.insert(entry)
        try? ctx.save()
        reload()
    }

    func toggleFavorite(_ entry: GratEntry) {
        entry.favorite.toggle()
        try? container.mainContext.save()
        reload()
    }

    func deleteEntry(_ entry: GratEntry) {
        container.mainContext.delete(entry)
        try? container.mainContext.save()
        reload()
    }

    func deleteAllData() {
        let ctx = container.mainContext
        let allEntries = (try? ctx.fetch(FetchDescriptor<GratEntry>())) ?? []
        for e in allEntries { ctx.delete(e) }
        let allPrompts = (try? ctx.fetch(FetchDescriptor<GratPrompt>())) ?? []
        for p in allPrompts { ctx.delete(p) }
        try? ctx.save()
        reload()
    }

    // Entries visible to free users (last 30)
    var freeEntries: [GratEntry] {
        Array(entries.prefix(30))
    }
}

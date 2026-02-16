import Foundation
import SwiftData

@MainActor
final class EntryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() throws -> [Entry] {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(for date: Date) throws -> Entry? {
        let targetDay = date.startOfDay
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { $0.day == targetDay }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Upsert

    func upsert(_ entry: Entry) throws {
        if let existing = try fetch(for: entry.day) {
            existing.question = entry.question
            existing.photoData = entry.photoData
            existing.reflection = entry.reflection
            existing.updatedAt = Date()
        } else {
            modelContext.insert(entry)
        }
        try modelContext.save()
    }

    // MARK: - Delete

    func delete(_ entry: Entry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }

    func delete(for date: Date) throws {
        if let entry = try fetch(for: date) {
            try delete(entry)
        }
    }
}

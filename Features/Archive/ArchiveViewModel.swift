import Foundation
import SwiftData

@MainActor
@Observable
final class ArchiveViewModel {
    private let repository: EntryRepository

    private(set) var entries: [Entry] = []

    init(repository: EntryRepository) {
        self.repository = repository
    }

    func loadEntries() {
        do {
            entries = try repository.fetchAll()
        } catch {
            print("Failed to fetch entries: \(error)")
            entries = []
        }
    }
}

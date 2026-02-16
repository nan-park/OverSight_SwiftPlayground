import Foundation
import SwiftData

@MainActor
@Observable
final class TodayViewModel {
    private let questionProvider: DailyQuestionProvider
    private let repository: EntryRepository

    var todayQuestion: String {
        questionProvider.todayQuestion
    }

    private(set) var todayEntry: Entry?

    init(
        questionProvider: DailyQuestionProvider = DailyQuestionProvider(),
        repository: EntryRepository
    ) {
        self.questionProvider = questionProvider
        self.repository = repository
    }

    func loadTodayEntry() {
        do {
            todayEntry = try repository.fetch(for: Date())
        } catch {
            print("Failed to fetch today's entry: \(error)")
            todayEntry = nil
        }
    }
}

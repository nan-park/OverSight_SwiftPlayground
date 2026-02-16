import Foundation

struct DailyQuestionProvider {
    private let questions: [String]

    init(questions: [String] = QuestionBank.questions) {
        self.questions = questions
    }

    func question(for date: Date) -> String {
        guard !questions.isEmpty else { return "" }

        let daysSinceReferenceDate = Calendar.current.dateComponents(
            [.day],
            from: Date(timeIntervalSinceReferenceDate: 0).startOfDay,
            to: date.startOfDay
        ).day ?? 0

        let index = abs(daysSinceReferenceDate) % questions.count
        return questions[index]
    }

    var todayQuestion: String {
        question(for: Date())
    }
}

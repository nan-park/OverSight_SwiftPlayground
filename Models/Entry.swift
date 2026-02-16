import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var day: Date
    var question: String
    var photoData: Data?
    var reflection: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        day: Date,
        question: String = "",
        photoData: Data? = nil,
        reflection: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.day = day.startOfDay
        self.question = question
        self.photoData = photoData
        self.reflection = reflection
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

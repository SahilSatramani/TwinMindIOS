

import Foundation
import SwiftData

@Model
class QAItem {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var dateAsked: Date
    @Relationship var session: RecordingSession?

    init(question: String, answer: String, dateAsked: Date = Date(), session: RecordingSession? = nil) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.dateAsked = dateAsked
        self.session = session
    }
}

import Foundation
import SwiftData

@Model
class RecordingSession {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var location: String
    var duration: TimeInterval
    var summary: String?
    @Relationship(deleteRule: .cascade) var transcriptChunks: [TranscriptChunk]
    @Relationship(deleteRule: .cascade) var questions: [QAItem]

    init(title: String, location: String, duration: TimeInterval = 0) {
        self.id = UUID()
        self.title = title
        self.date = Date()
        self.location = location
        self.duration = duration
        self.transcriptChunks = []
    }
}

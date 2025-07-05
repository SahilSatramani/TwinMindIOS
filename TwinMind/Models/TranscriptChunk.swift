import Foundation
import SwiftData

@Model
class TranscriptChunk {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var text: String
    @Relationship var session: RecordingSession?

    init(timestamp: Date, text: String, session: RecordingSession?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.text = text
        self.session = session
    }
}

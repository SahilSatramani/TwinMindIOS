import Foundation
import SwiftData

final class TranscriptionViewModel: ObservableObject {
    @Published var transcriptChunks: [TranscriptChunk] = []
    @Published var isPaused: Bool = false

    let recorder = AudioRecorderService()
    private let whisper = WhisperService()

    private var modelContext: ModelContext?
    var currentSession: RecordingSession?

    init() {
        recorder.onSegmentReady = { [weak self] fileURL, time in
            self?.transcribeSegment(fileURL: fileURL, time: time)
        }
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func start(with session: RecordingSession) {
        self.currentSession = session
        recorder.startRecording()
    }

    func stop() {
        recorder.stopRecording()

        guard let session = currentSession else { return }

        let transcript = transcriptChunks.map(\.text).joined(separator: "\n")
        let sessionRef = session  // Avoid capture in @Sendable

        OpenAIService.shared.summarizeTranscript(transcript) { [weak self] title, summary in
            DispatchQueue.main.async {
                sessionRef.title = title
                sessionRef.summary = summary
                self?.modelContext?.insert(sessionRef)
            }
        }
    }

    func pause() {
        recorder.pauseRecording()
        isPaused = true
    }

    func resume() {
        recorder.resumeRecording()
        isPaused = false
    }

    func togglePauseResume() {
        isPaused ? resume() : pause()
    }

    private func transcribeSegment(fileURL: URL, time: Date) {
        whisper.transcribeAudio(url: fileURL) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self,
                      let text = result,
                      let session = self.currentSession else { return }

                let chunk = TranscriptChunk(timestamp: time, text: text, session: session)
                self.transcriptChunks.append(chunk)
                self.modelContext?.insert(chunk)
                session.transcriptChunks.append(chunk)
            }
        }
    }

    func loadSession(_ session: RecordingSession) {
        self.transcriptChunks = session.transcriptChunks
    }

    func generateSummary(for session: RecordingSession) async {
        let transcript = transcriptChunks.map { $0.text }.joined(separator: "\n")

        guard transcript.count > 50 else {
            session.title = "Untitled"
            session.summary = "Transcript too short to generate a summary"
            return
        }

        // Step 1: Get title and summary WITHOUT capturing 'session' in the closure
        let (title, summary): (String, String) = await withCheckedContinuation { continuation in
            OpenAIService.shared.summarizeTranscript(transcript) { title, summary in
                continuation.resume(returning: (title, summary))
            }
        }

        // Step 2: Apply results to session OUTSIDE the continuation closure
        session.title = title.isEmpty ? "Untitled" : title
        session.summary = summary.isEmpty ? "Transcript too short to generate a summary" : summary
    }
}

import Foundation
import SwiftData

final class TranscriptionViewModel: ObservableObject {
    @Published var transcriptChunks: [TranscriptChunk] = []
    @Published var isPaused: Bool = false

    let recorder = AudioRecorderService()
    private let whisper = WhisperService()

    private var modelContext: ModelContext?
    private var currentSession: RecordingSession?

    init() {
        recorder.onSegmentReady = { [weak self] fileURL, time in
            self?.transcribeSegment(fileURL: fileURL, time: time)
        }
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func start() {
        let session = RecordingSession(title: "Untitled", location: "Boston")
        self.currentSession = session
        modelContext?.insert(session)
        recorder.startRecording()
    }

    func stop() {
        recorder.stopRecording()
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
}

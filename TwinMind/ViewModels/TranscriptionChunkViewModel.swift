import Foundation

struct TranscriptChunk: Identifiable {
    let id = UUID()
    let time: Date
    let text: String
}

final class TranscriptionViewModel: ObservableObject {
    @Published var transcriptChunks: [TranscriptChunk] = []

    private let recorder = AudioRecorderService()
    private let whisper = WhisperService()

    init() {
        recorder.onSegmentReady = { [weak self] fileURL, time in
            self?.transcribeSegment(fileURL: fileURL, time: time)
        }
    }

    func start() {
        recorder.startRecording()
    }

    func stop() {
        recorder.stopRecording()
    }

    private func transcribeSegment(fileURL: URL, time: Date) {
        whisper.transcribeAudio(url: fileURL) { [weak self] result in
            DispatchQueue.main.async {
                if let text = result {
                    self?.transcriptChunks.append(TranscriptChunk(time: time, text: text))
                }
            }
        }
    }
}

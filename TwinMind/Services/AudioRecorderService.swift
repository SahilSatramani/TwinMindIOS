import Foundation
import AVFoundation

final class AudioRecorderService: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    private var outputURL: URL?
    private let chunkDuration: TimeInterval = 30
    private var currentStartTime: Date = Date()

    var onSegmentReady: ((URL, Date) -> Void)?

    override init() {
        super.init()
        setupAudioSession()
        observeInterruptions()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
    }

    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            stopRecording()
        } else {
            try? AVAudioSession.sharedInstance().setActive(true)
            startRecording()
        }
    }

    func startRecording() {
        stopRecording()

        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0)
        let timestamp = Date()
        currentStartTime = timestamp
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("chunk-\(UUID().uuidString).wav")

        do {
            audioFile = try AVAudioFile(forWriting: outputURL!, settings: format.settings)
        } catch {
            print("Failed to create file:", error)
            return
        }

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            try? self.audioFile?.write(from: buffer)
        }

        try? audioEngine.start()

        timer = Timer.scheduledTimer(withTimeInterval: chunkDuration, repeats: true) { _ in
            self.splitSegment()
        }

        print("Recording started")
    }

    private func splitSegment() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()

        if let url = outputURL {
            onSegmentReady?(url, currentStartTime)
        }

        startRecording()  // Restart a new segment
    }

    func stopRecording() {
        timer?.invalidate()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    func pauseRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.pause()
        timer?.invalidate()
        print("Recording paused")
    }

    func resumeRecording() {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0)

        do {
            audioFile = try AVAudioFile(forWriting: outputURL!, settings: format.settings)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                try? self.audioFile?.write(from: buffer)
            }
            try audioEngine.start()

            timer = Timer.scheduledTimer(withTimeInterval: chunkDuration, repeats: true) { _ in
                self.splitSegment()
            }

            print("Recording resumed")
        } catch {
            print("Failed to resume recording:", error)
        }
    }
}

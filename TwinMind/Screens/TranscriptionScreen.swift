import SwiftUI
import SwiftData

enum TranscriptionTab: String, CaseIterable {
    case notes = "Notes"
    case transcript = "Transcript"
}

struct TranscriptionScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    let session: RecordingSession?
    let isReadOnly: Bool

    @State private var selectedTab: TranscriptionTab = .transcript
    @State private var sessionTitle: String = "Untitled"

    @StateObject private var viewModel = TranscriptionViewModel()

    @State private var recordingStartTime: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            // Header with title + timer
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(sessionTitle)
                        .font(.title3)
                        .bold()

                    Spacer()

                    if !isReadOnly {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                            Text(timeString(from: elapsedSeconds))
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }

                Text("\(formattedDateTime()) • Boston, MA")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            .onAppear {
                viewModel.setContext(modelContext)
                if isReadOnly, let session {
                    sessionTitle = session.title
                    viewModel.loadSession(session)
                } else {
                    viewModel.start()
                    startTimer()
                }
            }
            .onDisappear {
                if !isReadOnly {
                    viewModel.stop()
                    stopTimer()
                }
            }

            // Tabs
            HStack {
                ForEach(TranscriptionTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedTab == tab ? .blue : .clear)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)

            Divider()

            // Tab Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if selectedTab == .notes {
                        Text("Notes coming soon...")
                    } else {
                        ForEach(viewModel.transcriptChunks) { chunk in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formattedTime(chunk.timestamp))
                                    .font(.caption)
                                    .bold()
                                Text(chunk.text)
                            }
                            .padding(.vertical, 8)
                        }

                        if !isReadOnly {
                            Text("Transcript updates every 30s.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.top)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                .padding(.horizontal)
            }

            Spacer()

            // Bottom Controls
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Chat button (common to both modes)
                    Button(action: {
                        print("💬 Chat tapped")
                    }) {
                        HStack {
                            Image(systemName: "bubble.left")
                            Text("Chat with Transcript")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    if !isReadOnly {
                        Button(action: {
                            viewModel.togglePauseResume()
                        }) {
                            Text(viewModel.isPaused ? "Resume" : "Pause")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }

                        Button(action: {
                            viewModel.stop()
                            stopTimer()
                            dismiss()
                        }) {
                            Text("Stop")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    private func startTimer() {
        recordingStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = recordingStartTime {
                elapsedSeconds = Int(Date().timeIntervalSince(start))
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

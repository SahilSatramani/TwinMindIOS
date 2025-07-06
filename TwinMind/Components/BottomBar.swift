import SwiftUI

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 16) {
            // NavigationLink to create a new session
            NavigationLink(destination: TranscriptionScreen(session: RecordingSession(title: "Untitled", location: "Boston"), isReadOnly: false)) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Start New Recording")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
}

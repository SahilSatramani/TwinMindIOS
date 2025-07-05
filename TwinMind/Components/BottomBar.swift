import SwiftUI

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 16) {
            // Ask All Memories

            // NavigationLink to TranscriptionScreen
            NavigationLink(destination: TranscriptionScreen()) {
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

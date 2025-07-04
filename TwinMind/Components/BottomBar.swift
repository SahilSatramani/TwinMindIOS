import SwiftUI

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 16) {
            // Ask All Memories
            Button(action: {
                // Action
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Ask All Memories")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

            Spacer()

            // NavigationLink to TranscriptionScreen
            NavigationLink(destination: TranscriptionScreen()) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Capture")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
}

import SwiftUI
import SwiftData

struct BottomBar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var path: NavigationPath

    var body: some View {
        Button(action: {
            let session = RecordingSession(title: "Untitled", location: "Boston")
            modelContext.insert(session)
            path.append(session)
        }) {
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

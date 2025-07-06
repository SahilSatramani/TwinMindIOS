import SwiftUI
import SwiftData
import Speech

@main
struct TwinMindApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    //  Request permission for Apple Speech Recognition
                    SFSpeechRecognizer.requestAuthorization { status in
                        print(" Apple Speech Permission: \(status)")
                    }
                }
        }
        .modelContainer(for: [RecordingSession.self, TranscriptChunk.self])
    }
}

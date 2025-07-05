//
//  TwinMindApp.swift
//  TwinMind
//
//  Created by Sahil Satramani on 7/4/25.
//

import SwiftUI
import SwiftData

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
        }
        .modelContainer(for: [RecordingSession.self, TranscriptChunk.self])
    }
}

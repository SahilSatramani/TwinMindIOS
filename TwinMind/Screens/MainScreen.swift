import SwiftUI
import SwiftData

enum MainTab: String, CaseIterable {
    case memories = "Memories"
    case questions = "Questions"
}

struct MainScreen: View {
    @State private var selectedTab: MainTab = .memories
    @Query(sort: \RecordingSession.date, order: .reverse) var sessions: [RecordingSession]
    @State private var navPath = NavigationPath()

    var groupedSessions: [(String, [RecordingSession])] {
        Dictionary(grouping: sessions) { session in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: session.date)
        }
        .sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack(spacing: 0) {
                TopBar()
                Divider()

                // Tabs
                HStack {
                    ForEach(MainTab.allCases, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            VStack {
                                Text(tab.rawValue)
                                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                                    .fontWeight(selectedTab == tab ? .bold : .regular)
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(selectedTab == tab ? .blue : .clear)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)

                Divider()

                if selectedTab == .memories {
                    MemoriesTabView(sessions: sessions)
                } else if selectedTab == .questions {
                    QuestionsTabView()
                }

                BottomBar(path: $navPath)
                    .padding(.bottom, 8)
                    .padding(.horizontal)
            }
            .navigationDestination(for: RecordingSession.self) { session in
                TranscriptionScreen(session: session, isReadOnly: false)
            }
        }
    }
}

import SwiftUI
import SwiftData

enum MainTab: String, CaseIterable {
    case memories = "Memories"
    case questions = "Questions"
}

struct MainScreen: View {
    @State private var selectedTab: MainTab = .memories
    @Query(sort: \RecordingSession.date, order: .reverse) var sessions: [RecordingSession]

    var groupedSessions: [(String, [RecordingSession])] {
        Dictionary(grouping: sessions) { session in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: session.date)
        }
        .sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top
                TopBar()

                Divider()

                // Tabs
                HStack {
                    ForEach(MainTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
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

                // Content
                if selectedTab == .memories {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(groupedSessions, id: \.0) { (dateString, sessions) in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(dateString)
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(sessions) { session in
                                        NavigationLink(destination: TranscriptionScreen(session: session, isReadOnly: true)) {
                                            HStack {
                                                Text(formattedTime(session.date))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)

                                                VStack(alignment: .leading) {
                                                    Text(session.title)
                                                        .font(.subheadline)
                                                        .lineLimit(1)

                                                    Text("\(Int(session.duration / 60))m")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                } else if selectedTab == .questions {
                    Spacer()
                    Text("Questions tab coming soon")
                        .foregroundColor(.gray)
                }

                // Bottom
                BottomBar()
                    .padding(.bottom, 8)
                    .padding(.horizontal)
            }
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

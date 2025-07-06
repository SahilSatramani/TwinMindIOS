import SwiftUI
import SwiftData

struct MemoriesTabView: View {
    let sessions: [RecordingSession]

    var groupedSessions: [(String, [RecordingSession])] {
        Dictionary(grouping: sessions) { session in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: session.date)
        }
        .sorted { $0.key > $1.key }
    }

    var body: some View {
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
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

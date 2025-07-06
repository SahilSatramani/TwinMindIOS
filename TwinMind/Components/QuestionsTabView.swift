import SwiftUI
import SwiftData

struct QuestionsTabView: View {
    @Query(sort: \QAItem.dateAsked, order: .reverse) var qaItems: [QAItem]
    
    @State private var selectedQA: QAItem?
    @State private var showQAResponse = false

    var grouped: [(String, [QAItem])] {
        Dictionary(grouping: qaItems) { item in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: item.dateAsked)
        }
        .sorted { $0.key > $1.key }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(grouped, id: \.0) { (date, items) in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(date)
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(items) { qa in
                            Button {
                                selectedQA = qa
                                showQAResponse = true
                            } label: {
                                HStack {
                                    Image(systemName: "text.bubble")
                                        .foregroundColor(.blue)
                                    Text(qa.question)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .sheet(isPresented: $showQAResponse) {
            if let qa = selectedQA {
                QAResponseSheet(qaItem: qa, isPresented: $showQAResponse)
            }
        }
    }
}

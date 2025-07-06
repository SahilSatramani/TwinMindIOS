import SwiftUI
import SwiftData

struct TranscriptChatPanel: View {
    @Environment(\.modelContext) private var modelContext
    let transcriptText: String
    
    @Binding var isPresented: Bool
    
    let currentSession: RecordingSession

    @State private var userInput: String = ""
    @State private var response: String? = nil
    @State private var isLoading = false
    @State private var enableWebSearch = false

    private let suggestions = [
        "Summarize everything in great detail",
        "What did I miss in this conversation?",
        "Key decisions made?"
    ]

    var body: some View {
        VStack {
            // Top Close Button
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Ask anything...", text: $userInput)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            userInput = suggestion
                            askQuestion()
                        } label: {
                            HStack {
                                Text(suggestion)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }

                    Toggle("Web Search", isOn: $enableWebSearch)
                        .padding(.top)

                    if isLoading {
                        ProgressView()
                            .padding()
                    }

                    if let response {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Response:")
                                .font(.headline)
                            Text(response)
                        }
                        .padding()
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }

            HStack {
                TextField("Type your question...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: askQuestion) {
                    Text("Send")
                        .padding(.horizontal)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }

    private func askQuestion() {
        isLoading = true
        response = nil

        let question = userInput.trimmingCharacters(in: .whitespaces)
        OpenAIService.shared.ask(question: question, context: transcriptText, useWebSearch: enableWebSearch) { result in
            DispatchQueue.main.async {
                isLoading = false
                self.response = result ?? "No response received."
                
                if let answer = result?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let qa = QAItem(question: question, answer: answer, session: currentSession)
                    modelContext.insert(qa)
                    currentSession.questions.append(qa)
                }
            }
        }
    }
}

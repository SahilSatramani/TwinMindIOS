import Foundation

final class OpenAIService {
    static let shared = OpenAIService()

    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""

    func ask(question: String, context: String, useWebSearch: Bool = false, completion: @escaping (String?) -> Void) {
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant. Only answer based on the transcript provided. If unsure, say you don't know."],
            ["role": "user", "content": "Transcript: \(context)"],
            ["role": "user", "content": question]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7
        ]

        guard let url = URL(string: endpoint),
              let body = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("OpenAI call failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
    func summarizeTranscript(_ transcript: String, completion: @escaping (String, String) -> Void) {
        let prompt = """
        You are a helpful assistant. Analyze the following transcript of a meeting.

        If the content is too short, uninformative, or meaningless (e.g., contains filler words, silence, or empty phrases), then return:
        Title: Untitled
        Summary: Transcript too short or not meaningful enough to summarize.

        Otherwise, generate:
        1. A short, descriptive title (one line)
        2. A useful summary that includes sections like 'Summary', 'To-Do List', or 'Action Items' if relevant.

        Transcript:
        \(transcript)
        """

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant for summarizing meeting transcripts."],
                ["role": "user", "content": prompt]
            ]
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let body = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Invalid request")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {

                let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                let title = lines.first ?? "Untitled"
                let summary = lines.dropFirst().joined(separator: "\n")

                completion(title, summary)
            } else {
                print("Failed to summarize: \(error?.localizedDescription ?? "Unknown error")")
                completion("Untitled", "Transcript too short or not meaningful enough to summarize.")
            }
        }.resume()
    }
}

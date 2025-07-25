import Foundation
import Speech
import CryptoKit

final class WhisperService {
    private let apiKey: String = {
        let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
        if key.isEmpty {
            print("Warning: OPENAI_API_KEY not found in Info.plist")
        }
        return key
    }()

    private var failureCount = 0
    private let failureThreshold = 5

    func transcribeAudio(url: URL, completion: @escaping (String?) -> Void) {
        if failureCount >= failureThreshold {
            print("Falling back to Apple Speech API")
            transcribeWithApple(url: url, completion: completion)
            return
        }

        retryWithBackoff(maxRetries: 5, initialDelay: 1.0, task: { retryCompletion in
            self.makeWhisperCall(url: url) { result in
                retryCompletion(result)
            }
        }, completion: { finalResult in
            if let text = finalResult {
                self.failureCount = 0
                completion(text)
            } else {
                self.failureCount += 1
                print("Whisper failed. Failure count: \(self.failureCount)")
                if self.failureCount >= self.failureThreshold {
                    print("Reached failure threshold. Switching to local STT.")
                    self.transcribeWithApple(url: url, completion: completion)
                } else {
                    completion(nil)
                }
            }
        })
    }

    private func retryWithBackoff<T>(
        maxRetries: Int = 5,
        initialDelay: Double = 1.0,
        task: @escaping (@escaping (T?) -> Void) -> Void,
        completion: @escaping (T?) -> Void
    ) {
        var attempt = 0

        func execute() {
            task { result in
                if let result = result {
                    completion(result)
                } else if attempt >= maxRetries {
                    completion(nil)
                } else {
                    attempt += 1
                    let delay = pow(2.0, Double(attempt)) * initialDelay
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        execute()
                    }
                }
            }
        }

        execute()
    }

    private func makeWhisperCall(url: URL, completion: @escaping (String?) -> Void) {
        guard let encryptedData = try? Data(contentsOf: url),
              let decryptedData = try? EncryptionHelper.decrypt(encryptedData) else {
            print("Failed to decrypt audio for Whisper")
            completion(nil)
            return
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let filename = url.lastPathComponent

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(decryptedData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = json["text"] as? String {
                completion(text)
            } else {
                print("Whisper call failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }.resume()
    }

    private func transcribeWithApple(url: URL, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let encryptedData = try? Data(contentsOf: url),
                  let decryptedURL = try? self.decryptToTempFile(encryptedData) else {
                print("Failed to decrypt for Apple STT")
                completion(nil)
                return
            }

            let recognizer = SFSpeechRecognizer()
            let request = SFSpeechURLRecognitionRequest(url: decryptedURL)

            recognizer?.recognitionTask(with: request) { result, error in
                DispatchQueue.main.async {
                    if let text = result?.bestTranscription.formattedString {
                        self.failureCount = 0
                        completion(text)
                    } else {
                        print("Apple STT failed: \(error?.localizedDescription ?? "Unknown error")")
                        completion(nil)
                    }
                }
            }
        }
    }

    private func decryptToTempFile(_ encryptedData: Data) throws -> URL {
        let decrypted = try EncryptionHelper.decrypt(encryptedData)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("decrypted-\(UUID().uuidString).wav")
        try decrypted.write(to: tempURL, options: .atomic)
        return tempURL
    }
}

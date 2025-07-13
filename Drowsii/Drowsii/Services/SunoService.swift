import Foundation

class SunoService {
    static let shared = SunoService()
    private let baseURL = URL(string: "https://your-suno-api-endpoint.com/api/generate")! // Replace with actual endpoint
    
    func generateMusic(prompt: String, completion: @escaping (Result<URL, Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["prompt": prompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["audio_url"] as? String,
                  let audioURL = URL(string: urlString) else {
                completion(.failure(NSError(domain: "SunoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from Suno API."])))
                return
            }
            // Download the MP3 file
            self.downloadMP3(from: audioURL, completion: completion)
        }
        task.resume()
    }
    
    private func downloadMP3(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "SunoService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to download MP3."])))
                return
            }
            let fileManager = FileManager.default
            let soundsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Sounds")
            try? fileManager.createDirectory(at: soundsDir, withIntermediateDirectories: true)
            let destURL = soundsDir.appendingPathComponent(UUID().uuidString + ".mp3")
            do {
                try fileManager.moveItem(at: tempURL, to: destURL)
                completion(.success(destURL))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
} 

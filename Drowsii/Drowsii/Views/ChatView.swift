import SwiftUI
import GoogleGenerativeAI

struct ChatView: View {
    @State private var message: String = ""
    @State private var messages: [String] = ["Welcome to Drowsii! How can I help you sleep better tonight?"]
    @StateObject private var geminiService = GeminiService()
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.self) { msg in
                        HStack {
                            Text(msg)
                                .padding(12)
                                .background(Color("MidnightBlue").opacity(0.1))
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color("PastelBlue"), lineWidth: 2)
                                )
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            HStack {
                TextField("Type your message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("PastelBlue")))
                        .padding(.trailing, 8)
                }
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color("PastelBlue"))
                        .clipShape(Circle())
                }
                .disabled(isLoading || message.isEmpty)
            }
            .padding(.bottom)
        }
        .background(
            Image("Drowsii Sounds & Chat Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        let userMessage = message
        messages.append(userMessage)
        message = ""
        isLoading = true
        Task {
            do {
                let geminiResponse = try await geminiService.generateChatResponse(prompt: userMessage)
                DispatchQueue.main.async {
                    messages.append(geminiResponse)
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    messages.append("[Gemini Error: \(error.localizedDescription)]")
                    isLoading = false
                }
            }
        }
    }
} 
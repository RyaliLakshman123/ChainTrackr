//
//  Config.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import SwiftUI
import Foundation

struct Config: View {
    @State private var search: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("AI Test")
                .font(.title)
                .fontWeight(.bold)

            TextField("Ask anything...", text: $search)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Send") {
                Task { await performSearch() }
            }
            .disabled(search.isEmpty || isLoading)
            .buttonStyle(.borderedProminent)

            if isLoading {
                ProgressView("Thinking...")
            }

            // Fixed ScrollView with better formatting
            ScrollView {
                VStack {
                    Text(response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    
                    
                    Spacer(minLength: 50) // Extra space at bottom
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
    }
    
    private func performSearch() async {
        guard !search.isEmpty else { return }

        await MainActor.run {
            isLoading = true
            response = ""
        }

        do {
            let result = try await sendGroqRequest(message: search)
            await MainActor.run {
                response = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                response = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func sendGroqRequest(message: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant."
                ],
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 25500, // Increased from 150 to 500
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorString)")
                }
                throw URLError(.badServerResponse)
            }
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return "Could not parse response"
    }
}

#Preview {
    Config()
}

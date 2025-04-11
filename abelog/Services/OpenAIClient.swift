//
//  OpenAIClient.swift
//  abelog
//
//  Created by 崔 瑩斌 on 4/11/25.
//

import Foundation

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class OpenAIClient {
    static func sendPrompt(_ prompt: String, apiKey: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            model: "gpt-4",
            messages: [
                ChatMessage(role: "system", content: "あなたは親切なレストラン選びのアシスタントです。ユーザーの条件に合わせて最適なレストランを1つ選び、理由を丁寧に日本語で説明してください。"),
                ChatMessage(role: "user", content: prompt)
            ]
        )

        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ GPT 호출 오류: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode(ChatResponse.self, from: data),
                  let reply = response.choices.first?.message.content else {
                print("❌ GPT 응답 디코딩 실패")
                completion(nil)
                return
            }

            completion(reply)
        }.resume()
    }
}

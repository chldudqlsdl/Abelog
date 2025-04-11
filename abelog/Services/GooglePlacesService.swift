//
//  Untitled.swift
//  abelog
//
//  Created by 崔 瑩斌 on 4/11/25.
//

import Foundation

class GooglePlacesService {
    static func fetchRestaurants(
        location: String,
        radius: Int = 1000,
        keyword: String,
        apiKey: String,
        completion: @escaping ([Place]) -> Void
    ) {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = """
        https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=\(radius)&type=restaurant&keyword=\(encodedKeyword)&key=\(apiKey)
        """

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("❌ 응답 없음")
                completion([])
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("📦 API 응답 JSON:\n\(json)")
            }

            if let response = try? JSONDecoder().decode(PlacesResponse.self, from: data) {
                let limitedResults = Array(response.results.prefix(8)) // 최대 8개만 사용
                completion(limitedResults)
            } else {
                print("❌ JSON 디코딩 실패")
                if let text = String(data: data, encoding: .utf8) {
                    print("📄 응답 내용: \(text)")
                }
                completion([])
            }
        }.resume()
    }
}

struct PlacesResponse: Codable {
    let results: [Place]
}

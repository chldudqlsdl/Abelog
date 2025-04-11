//
//  Untitled.swift
//  abelog
//
//  Created by 崔 瑩斌 on 4/11/25.
//

import Foundation
import UIKit

struct Place: Codable, Identifiable {
    let id = UUID() // SwiftUI List에서 사용하기 좋음
    
    let name: String
    let rating: Double?
    let userRatingsTotal: Int?
    let vicinity: String
    let types: [String]?
    let businessStatus: String?
    let geometry: Geometry?
    let openingHours: OpeningHours?
    
    // 우리가 추가로 계산해서 넣는 필드
    var distanceFromUser: Double?  // 단위: 미터
    
    enum CodingKeys: String, CodingKey {
        case name, rating, vicinity, types, geometry
        case userRatingsTotal = "user_ratings_total"
        case businessStatus = "business_status"
        case openingHours = "opening_hours"
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct OpeningHours: Codable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

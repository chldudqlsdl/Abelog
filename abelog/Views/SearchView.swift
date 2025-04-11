//
//  ContentView.swift
//  abelog
//
//  Created by 崔 瑩斌 on 4/11/25.
//

import SwiftUI
import CoreLocation

struct SearchView: View {
    @State private var userInput: String = ""
    @State private var places: [Place] = []
    @StateObject private var locationManager = LocationManager()
    @State private var gptReply: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("条件を入力してください：")
                    .font(.headline)
                
                TextField("例: 静かな雰囲気のイタリアンでランチ", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    
                    self.gptReply = nil
                    self.isLoading = true
                    self.places = []
                    
                        guard let userLocation = locationManager.userLocation else {
                            isLoading = false
                            return
                        }
                    
                    let locationString = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
                    
                    GooglePlacesService.fetchRestaurants(
                        location: locationString,
                        keyword: userInput,
                        apiKey: Secrets.googleAPIKey
                    ) { results in
                        // 거리 계산 포함
                        let enrichedPlaces = results.map { place -> Place in
                            var copy = place
                            if let lat = place.geometry?.location.lat, let lng = place.geometry?.location.lng {
                                let placeLocation = CLLocation(latitude: lat, longitude: lng)
                                copy.distanceFromUser = calculateDistance(from: userLocation, to: placeLocation)
                            }
                            return copy
                        }
                        
                        // 프롬프트 생성
                        let prompt = makePrompt(from: enrichedPlaces, userCondition: userInput)
                        
                        // GPT 호출
                        OpenAIClient.sendPrompt(prompt, apiKey: Secrets.openAIKey) { reply in
                            DispatchQueue.main.async {
                                self.gptReply = reply
                                self.isLoading = false
                            }
                        }
                    }
                })  {
                    Text("検索")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                if isLoading {
                    Spacer()
                    ProgressView("検索中...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                
                if let reply = gptReply {
                    Text("GPTのおすすめ:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(reply)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("レストラン推薦AI")
        }
    }
}

func calculateDistance(from userLocation: CLLocation, to placeLocation: CLLocation) -> Double {
    return userLocation.distance(from: placeLocation) // 결과는 미터 단위
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

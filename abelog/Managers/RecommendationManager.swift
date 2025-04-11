//
//  Untitled.swift
//  abelog
//
//  Created by 崔 瑩斌 on 4/11/25.
//

func makePrompt(from places: [Place], userCondition: String) -> String {
    var prompt = """
    あなたはIT企業に勤める親切なアシスタントです。

    【前提】
    私はIT企業の新入社員です。  
    チームメンバーと一緒にランチやディナーに行く際に、お店を探す役割を任されることがあります。  
    しかし、まだこのエリアに慣れておらず、どんなお店があるのかもよくわかりません。

    そこで、私が入力した条件をもとに、候補一覧の中から最もおすすめのレストランを**1つだけ**選んでください。  
    「なぜそのお店が良いのか」も、雰囲気や距離、チームでの使いやすさなどを含めて日本語で丁寧に説明してください。

    【私の希望条件】
    \(userCondition)

    【候補一覧】
    """

    for (index, place) in places.enumerated() {
        let name = place.name
        let address = place.vicinity
        let rating = place.rating != nil ? "\(place.rating!)" : "評価なし"
        let reviews = place.userRatingsTotal ?? 0
        let types = place.types?.joined(separator: ", ") ?? "不明"
        let business = place.businessStatus ?? "不明"
        let distance = place.distanceFromUser != nil ? String(format: "%.0fm", place.distanceFromUser!) : "不明"

        prompt += """
        
        \(index + 1). \(name)
        - 住所: \(address)
        - 距離: \(distance)
        - 評価: \(rating)（レビュー数: \(reviews)）
        - 種類: \(types)
        - 営業状態: \(business)
        """
    }

    prompt += """

    【お願い】
    候補の中から1つだけ最適なお店を選び、その理由を簡潔に日本語で説明してください。
    """

    return prompt
}



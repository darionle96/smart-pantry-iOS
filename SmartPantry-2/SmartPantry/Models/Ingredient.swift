//
//  Ingredient.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    var description: String? = nil   // API List has none but would work if it did

    var thumbURL: URL? {
        let encoded = name.replacingOccurrences(of: " ", with: "%20")
        return URL(string: "https://www.themealdb.com/images/ingredients/\(encoded).png")
    }
}

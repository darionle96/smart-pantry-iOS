//
//  Meal.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

struct MealSummary: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let thumb: URL?

    init(id: String, name: String, thumbString: String?) {
        self.id = id
        self.name = name
        if let s = thumbString { self.thumb = URL(string: s) } else { self.thumb = nil }
    }
}

struct MealDetail: Identifiable, Codable {
    let id: String
    let name: String
    let instructions: String
    let thumb: URL?
    let ingredients: [String]

    init(id: String, name: String, instructions: String, thumbString: String?, ingredients: [String]) {
        self.id = id
        self.name = name
        self.instructions = instructions
        self.thumb = thumbString.flatMap(URL.init(string:))
        self.ingredients = ingredients
    }
}

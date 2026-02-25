//
//  MealDBService.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

final class MealDBService {
    static let shared = MealDBService() // One client anywhere
    private init() {}

    // Ingredient List
    private var cachedIngredients: [Ingredient] = [] // Memory cache of ingredient names
    private var hasLoadedIngredients = false // No refresh on full list
    
    
    // Ingredient Details
    struct IngredientInfo: Decodable {
        let idIngredient: String?
        let strIngredient: String?
        let strDescription: String?
        let strType: String?
    }

    // MARK: Fetch

    // Fetch extra metadata for a single ingredient by name
    func fetchIngredientDetail(name: String) async throws -> (description: String?, type: String?)? {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?i=\(encoded)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)

        struct Resp: Decodable { let ingredients: [IngredientInfo]? }
        let decoded = try JSONDecoder().decode(Resp.self, from: data)
        guard let info = decoded.ingredients?.first else { return nil }
        return (info.strDescription, info.strType)
    }

    // Load full list of ingredients once and cache it in memory
    func loadAllIngredients() async throws -> [Ingredient] { // Fetch and Cache of all names
        if hasLoadedIngredients { return cachedIngredients } // No re-hits on network after first load
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/list.php?i=list") else {
            return []
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Resp: Decodable { let meals: [Item]? }
        struct Item: Decodable { let strIngredient: String? }

        let decoded = try JSONDecoder().decode(Resp.self, from: data)
        let names = decoded.meals?
            .compactMap { $0.strIngredient?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        let list = names.map { Ingredient(name: $0) }.sorted { $0.name < $1.name }
        cachedIngredients = list
        hasLoadedIngredients = true
        return list
    }

    // MARK: Searching

    // Search locally in cached ingredient instead of network hits
    func searchIngredientsLocally(_ query: String) async throws -> [Ingredient] {
        let all = try await loadAllIngredients()     // Is cache populated first?
        if query.isEmpty { return Array(all.prefix(30)) }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
                  .prefix(50) // Hard limit results
                  .map { $0 }
    }

    // Search meals, fuzzy name/keyword.
    func searchMeals(_ query: String) async throws -> [MealSummary] {
        guard !query.isEmpty else { return [] }
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)

        struct Resp: Decodable { let meals: [Meal]? }
        struct Meal: Decodable { let idMeal: String; let strMeal: String; let strMealThumb: String? }

        let decoded = try JSONDecoder().decode(Resp.self, from: data)
        return (decoded.meals ?? []).map { MealSummary(id: $0.idMeal, name: $0.strMeal, thumbString: $0.strMealThumb) }
    }

    // Fetch meal detail, all ingredients/measures by ID
    func fetchMealDetail(id: String) async throws -> MealDetail? {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)

        struct Resp: Decodable { let meals: [Meal]? }
        struct Meal: Decodable {
            let idMeal: String
            let strMeal: String
            let strInstructions: String?
            let strMealThumb: String?
////////////////////////////qweqwrewrwerewrwerwerwe
            // TheMealDB has 20 ingredient/measure pairs as separate fields listed here
            let strIngredient1: String?;  let strMeasure1: String?
            let strIngredient2: String?;  let strMeasure2: String?
            let strIngredient3: String?;  let strMeasure3: String?
            let strIngredient4: String?;  let strMeasure4: String?
            let strIngredient5: String?;  let strMeasure5: String?
            let strIngredient6: String?;  let strMeasure6: String?
            let strIngredient7: String?;  let strMeasure7: String?
            let strIngredient8: String?;  let strMeasure8: String?
            let strIngredient9: String?;  let strMeasure9: String?
            let strIngredient10: String?; let strMeasure10: String?
            let strIngredient11: String?; let strMeasure11: String?
            let strIngredient12: String?; let strMeasure12: String?
            let strIngredient13: String?; let strMeasure13: String?
            let strIngredient14: String?; let strMeasure14: String?
            let strIngredient15: String?; let strMeasure15: String?
            let strIngredient16: String?; let strMeasure16: String?
            let strIngredient17: String?; let strMeasure17: String?
            let strIngredient18: String?; let strMeasure18: String?
            let strIngredient19: String?; let strMeasure19: String?
            let strIngredient20: String?; let strMeasure20: String?
        }

        // Combine ingredient/measure pair into 1 string
        func compactPair(_ ing: String?, _ meas: String?) -> String? {
            let ing = (ing ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let meas = (meas ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !ing.isEmpty else { return nil }         // Skip empty slots
            return meas.isEmpty ? ing : "\(meas) \(ing)"   // Combine “1 cup” + “Sugar” -> “1 cup Sugar”
        }

        let decoded = try JSONDecoder().decode(Resp.self, from: data)
        guard let m = decoded.meals?.first else { return nil }
        let pairs: [String?] = [
            compactPair(m.strIngredient1, m.strMeasure1),
            compactPair(m.strIngredient2, m.strMeasure2),
            compactPair(m.strIngredient3, m.strMeasure3),
            compactPair(m.strIngredient4, m.strMeasure4),
            compactPair(m.strIngredient5, m.strMeasure5),
            compactPair(m.strIngredient6, m.strMeasure6),
            compactPair(m.strIngredient7, m.strMeasure7),
            compactPair(m.strIngredient8, m.strMeasure8),
            compactPair(m.strIngredient9, m.strMeasure9),
            compactPair(m.strIngredient10, m.strMeasure10),
            compactPair(m.strIngredient11, m.strMeasure11),
            compactPair(m.strIngredient12, m.strMeasure12),
            compactPair(m.strIngredient13, m.strMeasure13),
            compactPair(m.strIngredient14, m.strMeasure14),
            compactPair(m.strIngredient15, m.strMeasure15),
            compactPair(m.strIngredient16, m.strMeasure16),
            compactPair(m.strIngredient17, m.strMeasure17),
            compactPair(m.strIngredient18, m.strMeasure18),
            compactPair(m.strIngredient19, m.strMeasure19),
            compactPair(m.strIngredient20, m.strMeasure20)
        ]
        let list = pairs.compactMap { $0 } // Remove nils

        return MealDetail(id: m.idMeal, name: m.strMeal, instructions: m.strInstructions ?? "", thumbString: m.strMealThumb, ingredients: list)

    }
    /*               AAAAAAAAAAAAAAAAAAAAAAAAA */
    
    // MARK: Random Recipe Fetch

    // Fetch a random meal
    func fetchRandomMeal() async throws -> MealDetail? {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct Resp: Decodable { let meals: [Meal]? }
        struct Meal: Decodable {
            let idMeal: String
            let strMeal: String
            let strInstructions: String?
            let strMealThumb: String?
            // Only a subset is decoded for the random call, can extend to 20 if needed
            let strIngredient1: String?;  let strMeasure1: String?
            let strIngredient2: String?;  let strMeasure2: String?
            let strIngredient3: String?;  let strMeasure3: String?
            let strIngredient4: String?;  let strMeasure4: String?
            let strIngredient5: String?;  let strMeasure5: String?
        }
        
        // This is a redundant repeat from a function above but it works so lets not bother in case it breaks something
        func compactPair(_ ing: String?, _ meas: String?) -> String? {
            let ing = (ing ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let meas = (meas ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !ing.isEmpty else { return nil }
            return meas.isEmpty ? ing : "\(meas) \(ing)"
        }
        
        let decoded = try JSONDecoder().decode(Resp.self, from: data)
        guard let m = decoded.meals?.first else { return nil }
        let list: [String] = [
            compactPair(m.strIngredient1, m.strMeasure1),
            compactPair(m.strIngredient2, m.strMeasure2),
            compactPair(m.strIngredient3, m.strMeasure3),
            compactPair(m.strIngredient4, m.strMeasure4),
            compactPair(m.strIngredient5, m.strMeasure5)
        ].compactMap { $0 }
        
        return MealDetail(
            id: m.idMeal,
            name: m.strMeal,
            instructions: m.strInstructions ?? "",
            thumbString: m.strMealThumb,
            ingredients: list
        )
    }
}

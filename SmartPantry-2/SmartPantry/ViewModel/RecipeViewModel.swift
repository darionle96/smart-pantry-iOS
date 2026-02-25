//
//  RecipeViewModel.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

@MainActor
final class RecipeViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [MealSummary] = []
    @Published var isSearching = false
    private let service = MealDBService.shared

    func runSearch() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []; return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            results = try await service.searchMeals(query)
        } catch {
            results = []
        }
    }

    // DEPRACATED UNUSED
    /*
    func fetchDetail(id: String) async -> MealDetail? {
        try? await service.fetchMealDetail(id: id)
    }*/
}


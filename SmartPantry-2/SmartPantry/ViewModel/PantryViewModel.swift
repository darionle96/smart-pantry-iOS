//
//  PantryVM.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

@MainActor
final class PantryViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [Ingredient] = []
    @Published var isLoading = false
    private let service = MealDBService.shared

    func search() async {
        isLoading = true
        defer { isLoading = false }
        do {
            suggestions = try await service.searchIngredientsLocally(query)
        } catch {
            suggestions = []
        }
    }
}

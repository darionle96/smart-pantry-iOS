//
//  Store.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation
import SwiftUI

@MainActor
final class Store: ObservableObject {
    // Pantry ownership
    @Published var pantry: [PantryItem] = [] { didSet { save() } }
    // Favorite recipes
    @Published var favorites: [FavoritesRecipe] = [] { didSet { save() } }
    // Grocery list to buy (different than normal pantry)
    @Published var grocery: [PantryItem] = [] { didSet { save() } }

    private let fileURL: URL

    // Initialize store, load persisted data
    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = dir.appendingPathComponent("smartgrocery.json")
        load()
    }

    // Add/Remove Favorites
    func toggleFavorite(recipe: MealDetail) {
        if let index = favorites.firstIndex(where: { $0.id == recipe.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(FavoritesRecipe(id: recipe.id,
                                             name: recipe.name,
                                             thumb: recipe.thumb))
        }
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains(where: { $0.id == id })
    }

    @discardableResult
    func addIngredientsToPantry(_ ingredientNames: [String]) -> Int {
        let cleaned = ingredientNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleaned.isEmpty else { return 0 }

        // Return for counts of items
        for name in cleaned {
            if let idx = pantry.firstIndex(where: {
                $0.ingredientName.caseInsensitiveCompare(name) == .orderedSame // Check if same item
            }) {
                pantry[idx].quantity += 1
                pantry[idx].isChecked = false
            } else {
                pantry.append(PantryItem(ingredientName: name, quantity: 1)) // New item
            }
        }
        return cleaned.count
    }


    @discardableResult
    func addIngredientsToGrocery(_ ingredientNames: [String]) -> Int {
        let cleaned = ingredientNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleaned.isEmpty else { return 0 }

        for name in cleaned {
            if let idx = grocery.firstIndex(where: {
                $0.ingredientName.caseInsensitiveCompare(name) == .orderedSame
            }) {
                grocery[idx].quantity += 1
                grocery[idx].isChecked = false
            } else {
                grocery.append(PantryItem(ingredientName: name, quantity: 1))
            }
        }
        return cleaned.count
    }

    // Move all Grocery items into Pantry, also clear the list.
    func updatePantryFromGrocery() {
        for g in grocery {
            if let idx = pantry.firstIndex(where: {
                $0.ingredientName.caseInsensitiveCompare(g.ingredientName) == .orderedSame
            }) {
                pantry[idx].quantity += g.quantity // Same item +1
                pantry[idx].isChecked = false
            } else {
                pantry.append(PantryItem(ingredientName: g.ingredientName, // Diff item add
                                         quantity: g.quantity,
                                         isChecked: false))
            }
        }
        grocery.removeAll()
    }

    // PERSISTENCE

    private struct DataBlob: Codable {
        var pantry: [PantryItem]
        var favorites: [FavoritesRecipe]
        var grocery: [PantryItem]
    }

    // Load persistence data from disk
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        guard let data = try? Data(contentsOf: fileURL) else { return }
        guard let blob = try? JSONDecoder().decode(DataBlob.self, from: data) else { return }

        pantry = blob.pantry
        favorites = blob.favorites
        grocery = blob.grocery
    }

    // Persist Pantry
    private func save() {
        let blob = DataBlob(pantry: pantry, favorites: favorites, grocery: grocery)
        guard let data = try? JSONEncoder().encode(blob) else { return }
        try? data.write(to: fileURL)
    }
}

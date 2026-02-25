//
//  MealDetailView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//
//

import SwiftUI

struct MealDetailView: View {
    @EnvironmentObject private var store: Store
    let mealID: String

    @State private var detail: MealDetail?
    @State private var isLoading = true

    @State private var pantryConfirmation: String?
    @State private var groceryConfirmation: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(detail: detail)

                        if !ingredientNames.isEmpty {
                            ingredientsSection
                            addButtonsSection
                        }

                        if !detail.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            instructionsSection(detail: detail)
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Meal details could not be loaded.")
                )
            }
        }
        .navigationTitle("Recipe")
        .task {
            await load() // Fetch trigger 1st appearance
        }
    }

    // Flatten raw ingredient fields into clean string list
    private var ingredientNames: [String] {
        (detail?.ingredients ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } // Drop blank ingredient
    }

    // Image, title, and favorite button
    private func header(detail: MealDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: detail.thumb) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle()
                            .fill(AppTheme.surface)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle()
                            .fill(AppTheme.surface)
                        Image(systemName: "fork.knife.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detail.name)
                        .font(.title2.bold())
                    Text("From TheMealDB")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    store.toggleFavorite(recipe: detail)
                } label: {
                    Image(systemName: store.isFavorite(id: detail.id) ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: store.isFavorite(id: detail.id)) // Bounce toggle animation
                }
                .buttonStyle(.plain)
                .accessibilityLabel(store.isFavorite(id: detail.id) ? "Remove from favorites" : "Add to favorites")
            }
        }
    }

    // List all recipe ingredients
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)

            // Index as ID to avoid duplicate ID warnings
            ForEach(Array(ingredientNames.enumerated()), id: \.offset) { _, ingredient in
                // .enumerated() -> duplicate ingredient strings get unique IDs
                HStack {
                    Circle()
                        .fill(AppTheme.accentSoft)
                        .frame(width: 8, height: 8)
                    Text(ingredient)
                }
            }
        }
    }

    // Add all - buttons to pantry and grocery, confirmations
    private var addButtonsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    addAllToPantry()
                } label: {
                    Label("To Pantry (\(ingredientNames.count))", systemImage: "tray.full.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)

                Button {
                    addAllToGrocery()
                } label: {
                    Label("To Grocery (\(ingredientNames.count))", systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.tomato)
            }

            if let pantryConfirmation {
                Label(pantryConfirmation, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }

            if let groceryConfirmation {
                Label(groceryConfirmation, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        }
        .padding(.top, 4)
    }

    // Cooking instructions in plain text.
    private func instructionsSection(detail: MealDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)
            Text(detail.instructions)
                .font(.body)
        }
    }

    // Add all to Pantry, confirmation
    private func addAllToPantry() {
        let added = store.addIngredientsToPantry(ingredientNames)
        guard added > 0 else { return }

        pantryConfirmation = "Added \(added) ingredient\(added == 1 ? "" : "s") to Pantry"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            pantryConfirmation = nil                  // Auto-clear confirmation toast
        }
    }

    // Add all to Grocery, confirmation
    private func addAllToGrocery() {
        let added = store.addIngredientsToGrocery(ingredientNames)
        guard added > 0 else { return }

        groceryConfirmation = "Added \(added) ingredient\(added == 1 ? "" : "s") to Grocery List"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            groceryConfirmation = nil // Auto clear
        }
    }

    // Fetch detail info from TheMealDB ID
    private func load() async {
        isLoading = true
        defer { isLoading = false } // Loading flag resets even on fail
        detail = try? await MealDBService.shared.fetchMealDetail(id: mealID)
    }
}

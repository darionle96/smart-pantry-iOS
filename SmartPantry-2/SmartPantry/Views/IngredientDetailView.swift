//
//  IngredientDetailView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/29/25.
//

import SwiftUI

struct IngredientDetailView: View {
    @EnvironmentObject private var store: Store
    let ingredientName: String

    @State private var descriptionText: String = ""
    @State private var thumbURL: URL?
    @State private var qty: Int = 1
    @State private var loading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                AsyncImage(url: thumbURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit() // Full image scale
                    default:
                        Color.gray.opacity(0.12)
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Title and stepper for 0 quantity
                HStack {
                    Text(ingredientName)
                        .font(.title2.bold())
                    Spacer()
                    QuantityStepper(value: $qty) // Min value
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description").font(.headline)
                    if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("No description available.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(descriptionText)
                            .foregroundStyle(.secondary)
                    }
                }

                // Add to Grocery / Add to Pantry
                VStack(spacing: 10) {
                    Button {
                        guard qty > 0 else { return }
                        if let idx = store.grocery.firstIndex(where: {
                            $0.ingredientName.caseInsensitiveCompare(ingredientName) == .orderedSame
                        }) {
                            // If in grocery, increment quantity and reset checked state
                            store.grocery[idx].quantity += qty
                            store.grocery[idx].isChecked = false
                        } else {
                            store.grocery.append(.init(ingredientName: ingredientName, quantity: qty))
                        }
                    } label: {
                        Label("Add to Grocery List", systemImage: "cart.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .disabled(qty == 0)                    // Can't 0 quantity add

                    Button {
                        guard qty > 0 else { return }
                        if let idx = store.pantry.firstIndex(where: {
                            $0.ingredientName.caseInsensitiveCompare(ingredientName) == .orderedSame
                        }) {
                            store.pantry[idx].quantity += qty
                            store.pantry[idx].isChecked = false
                        } else {
                            store.pantry.append(.init(ingredientName: ingredientName, quantity: qty))
                        }
                    } label: {
                        Label("Add to Pantry", systemImage: "tray.and.arrow.down.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.accent)
                    .disabled(qty == 0)
                }
            }
            .padding()
        }
        .navigationTitle("Ingredient")
        .task {
            loading = true
            thumbURL = Ingredient(name: ingredientName).thumbURL // Thumbnail from ingredient name
            let detail = try? await MealDBService.shared.fetchIngredientDetail(name: ingredientName)
            descriptionText = (detail?.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            loading = false
        }
    }
}

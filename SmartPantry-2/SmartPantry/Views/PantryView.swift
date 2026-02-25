//
//  PantryView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//
//

import SwiftUI

struct PantryView: View {
    @EnvironmentObject private var store: Store
    @State private var confirmClear = false

    // Main view displaying and editing pantry items
    var body: some View {
        List {
            if store.pantry.isEmpty {
                Text("No items yet. Add some from the Ingredients tab.")
                    .foregroundStyle(.secondary)
            } else {
                // Indices help for safe deletion
                ForEach(store.pantry.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        NavigationLink {
                            IngredientDetailView(ingredientName: store.pantry[i].ingredientName)
                        } label: {
                            HStack(spacing: 12) {
                                AsyncImage(url: Ingredient(name: store.pantry[i].ingredientName).thumbURL) { phase in
                                    switch phase {
                                    case .success(let img): img.resizable().scaledToFill()
                                    default: Color.gray.opacity(0.15)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(store.pantry[i].ingredientName)
                                        .font(.headline)
                                    Text("Qty: \(store.pantry[i].quantity)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer(minLength: 8)

                        // Inline quantity stepper
                        QuantityStepper(value: $store.pantry[i].quantity)
                            .frame(minWidth: 120)
                            .onChange(of: store.pantry[i].quantity) { oldValue, newValue in
                                // Remove item when quantity hits <= 0
                                if newValue <= 0 {
                                    store.pantry.remove(at: i)
                                }
                            }
                    }
                    .padding(.vertical, 4)
                    .swipeActions {
                        Button(role: .destructive) {
                            store.pantry.remove(at: i)
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Pantry")
        .toolbar {
            if !store.pantry.isEmpty {
                Menu {
                    Button("Clear All", role: .destructive) { confirmClear = true }
                } label: { Label("More", systemImage: "ellipsis.circle") }
            }
        }
        .alert("Remove all pantry items?", isPresented: $confirmClear) {
            Button("Cancel", role: .cancel) {}
            Button("Remove All", role: .destructive) { store.pantry.removeAll() }
        }
    }
}

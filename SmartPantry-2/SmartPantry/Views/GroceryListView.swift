//
//  GroceryListView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//
//

import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject private var store: Store
    @State private var confirmClear = false
    @State private var pantryUpdateMessage: String?

    var body: some View {
        List {
            if let message = pantryUpdateMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .padding(.vertical, 4)
            }

            if store.grocery.isEmpty {
                ContentUnavailableView(
                    "Grocery list is empty",
                    systemImage: "cart",
                    description: Text("Add items from recipes or ingredients to start building your list.")
                )
            } else {
                ForEach($store.grocery) { $item in
                    // Using binding in ForEach so row can mutate PantryItem directly
                    GroceryRow(item: $item)
                }
                .onDelete { offsets in
                    store.grocery.remove(atOffsets: offsets)
                }
            }
        }
        .animation(.default, value: store.grocery) // Animate changes in list
        .navigationTitle("Grocery List")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    guard !store.grocery.isEmpty else { return }
                    store.updatePantryFromGrocery() // Moves all into pantry and clears grocery
                    pantryUpdateMessage = "Moved all grocery items into Pantry"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        pantryUpdateMessage = nil  // Auto hide after delay
                    }
                } label: {
                    Label("Update Pantry", systemImage: "tray.and.arrow.down.fill")
                }
                .disabled(store.grocery.isEmpty)

                Menu {
                    Button("Clear List", role: .destructive) {
                        confirmClear = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Clear grocery list?", isPresented: $confirmClear) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                store.grocery.removeAll()
            }
        } message: {
            Text("This removes all items from your grocery list.")
        }
    }
}

// Grocery row with checkmark and quantity
private struct GroceryRow: View {
    @Binding var item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            // Non-functional checkmark for visual purposes
            Button {
                item.isChecked.toggle()
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredientName)
                    .font(.headline)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)

                Text("Qty: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

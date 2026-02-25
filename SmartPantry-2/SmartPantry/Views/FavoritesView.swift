//
//  FavoritesView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: Store
    @StateObject private var vm = FavoritesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Picker("Favorites Type", selection: $vm.showRecipes) {
                Text("Recipes").tag(true)
                Text("Pantry").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if vm.showRecipes {
                RecipesList(store: store)
            } else {
                PantryFavoritesList(store: store)      // Reuses pantry data, actually not implemented as actual favs
            }
        }
        .navigationTitle("Favorites")
        .background(AppTheme.background.ignoresSafeArea())
    }
}

// Shows favorited recipes as list of navigation links
private struct RecipesList: View {
    @ObservedObject var store: Store // ObservedObject so child updates when Store changes

    var body: some View {
        List {
            if store.favorites.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No favorite recipes yet")
                        .font(.headline)
                    Text("Tap the heart on a recipe to save it here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else {
                ForEach(store.favorites) { fav in
                    NavigationLink {
                        MealDetailView(mealID: fav.id)
                    } label: {
                        RecipeRow(fav: fav)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct PantryFavoritesList: View {
    @ObservedObject var store: Store

    // Sorted pantry items
    private var items: [PantryItem] {
        // Sort alphabetically
        store.pantry.sorted { $0.ingredientName.localizedCaseInsensitiveCompare($1.ingredientName) == .orderedAscending }
    }

    var body: some View {
        List {
            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No pantry items yet")
                        .font(.headline)
                    Text("Add ingredients from the Pantry tab.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else {
                ForEach(items) { item in
                    HStack {
                        Text(item.ingredientName)
                            .font(.headline)
                        Spacer()
                        Text("×\(item.quantity)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// Single row for saved fav recipe
private struct RecipeRow: View {
    let fav: FavoritesRecipe

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: fav.thumb) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.accentSoft)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(fav.name)
                .font(.headline)
                .lineLimit(2)

            Spacer()

            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

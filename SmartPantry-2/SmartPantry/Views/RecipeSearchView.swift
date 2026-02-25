//
//  RecipeSearchView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

struct RecipeSearchView: View {
    @EnvironmentObject private var store: Store
    @StateObject private var vm = RecipeViewModel()

    // Root view for searching and listing recipes.
    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if vm.isSearching {
                ProgressView("Searching…")
                    .padding()
            }

            if vm.results.isEmpty &&
                !vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !vm.isSearching {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No recipes found")
                        .font(.headline)
                    Text("Try a different ingredient or dish name.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(vm.results) { meal in
                        NavigationLink {
                            MealDetailView(mealID: meal.id)
                        } label: {
                            MealRow(meal: meal)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Recipes")
        .background(AppTheme.background.ignoresSafeArea())
    }
    
    // Search bar UI, enter recipe query.
    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search recipes (e.g., chicken, pasta)", text: $vm.query)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        Task { await vm.runSearch() }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))

            Button {
                Task { await vm.runSearch() }
            } label: {
                Text("Go")
                    .padding(.horizontal, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(10)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12))
        .padding([.horizontal, .top])
    }
}

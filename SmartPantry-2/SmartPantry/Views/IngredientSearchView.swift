//
//  IngredientSearchView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/29/25.
//

import SwiftUI

struct IngredientSearchView: View {
    @StateObject private var vm = PantryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            if vm.isLoading { ProgressView("Loading…").padding(.top, 8) }
            List {
                Section("Ingredients") {
                    ForEach(vm.suggestions) { ing in
                        NavigationLink {
                            IngredientDetailView(ingredientName: ing.name)
                        } label: {
                            IngredientRow(name: ing.name, thumbURL: ing.thumbURL)
                            
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Ingredients")
        .onChange(of: vm.query) {
            // Re-run search when query text changes
            Task { await vm.search() }
        }
        .task { await vm.search() } // Initial load
    }

    // Search bar for ingredient name + clear button
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search ingredients (e.g., banana, milk)", text: $vm.query)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if !vm.query.isEmpty {
                Button { vm.query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
            }
        }
        .padding(10)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 12))
        .padding([.horizontal, .top])
    }
}

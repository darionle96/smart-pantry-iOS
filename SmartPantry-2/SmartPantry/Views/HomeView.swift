//
//  HomeView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: Store
    @State private var randomMeal: MealDetail? = nil
    @State private var isLoading = false
    @State private var showRandom = false     // Controls navigation to random recipe detail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                heroCard

                // Quick stats
                HStack(spacing: 12) {
                    statCard(
                        title: "Pantry",
                        value: "\(store.pantry.count) items",
                        icon: "tray.full.fill",
                        color: AppTheme.accent
                    )
                    statCard(
                        title: "Favorites",
                        value: "\(store.favorites.count) recipes",
                        icon: "heart.fill",
                        color: AppTheme.tomato
                    )
                }
                .padding(.top)

                // Homepage Recipe direct
                VStack(alignment: .leading, spacing: 12) {
                    Text("Find a recipe")
                        .font(.headline)

                    NavigationLink {
                        RecipeSearchView()
                    } label: {
                        actionRow(title: "Search recipes", icon: "fork.knife")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("Home")
        // Navigate to the random recipe detail page
        .navigationDestination(isPresented: $showRandom) {
            // Navigation uses state instead of NavigationLink directly
            if let meal = randomMeal {
                MealDetailView(mealID: meal.id)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("What are we cooking today?")
                .font(.title.bold())
        }
        .padding(.top, 8)
    }

    // Gradient card with “Surprise me” random recipe button
    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.tomato],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                Text("Use up your pantry")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Get a random recipe idea and add ingredients straight to your lists.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                Button {
                    // Random meal request into navigate
                    Task {
                        isLoading = true
                        defer { isLoading = false } // Ensure loading flag offs on all paths
                        randomMeal = try? await MealDBService.shared.fetchRandomMeal()
                        if randomMeal != nil {
                            showRandom = true // Triggers navigationDestination
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: isLoading ? "hourglass" : "dice.fill")
                            .font(.title3)
                            .symbolEffect(.bounce, value: isLoading)  // Reanimates icon while loading
                        Text(isLoading ? "Loading…" : "Surprise me with a recipe")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isLoading) // Stops API Spam while requesting in progress
                .padding(.top, 4)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }

    // Small stat card for counts
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // Row style button, used for “Search recipes”.
    private func actionRow(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(AppTheme.accentSoft, in: RoundedRectangle(cornerRadius: 10))

            Text(title)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}

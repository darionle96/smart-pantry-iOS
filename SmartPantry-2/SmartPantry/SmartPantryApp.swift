//
//  SmartPantryApp.swift
//  SmartPantry
//
//  Created by Darion Le on 10/26/25.
//
//

import SwiftUI

@main
struct SmartPantryApp: App {
    @StateObject private var store = Store()   // Single shared Store instance for entire app
    @State private var showSplash = true       // Controls whether splash is visible

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity.combined(with: .scale))
                } else {
                    MainTabView()
                        .environmentObject(store)  // Inject global Store into tab hierarchy
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Splash Loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeOut) {
                        showSplash = false // Swap to main content after delay
                    }
                }
            }
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { IngredientSearchView() }
                .tabItem { Label("Ingredients", systemImage: "magnifyingglass") }

            NavigationStack { PantryView() }
                .tabItem { Label("Pantry", systemImage: "tray.full.fill") }

            NavigationStack { GroceryListView() }
                .tabItem { Label("Grocery", systemImage: "checklist") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
        }
        .tint(AppTheme.accent)
        .toolbarBackground(AppTheme.tabBar, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)  // Force background show
    }
}

// Simple splash screen
private struct SplashView: View {
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentSoft)
                        .frame(width: 120, height: 120)

                    Image(systemName: "cart.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                }

                Text("SmartPantry")
                    .font(.largeTitle.bold())

                Text("Cook smarter with what you have.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

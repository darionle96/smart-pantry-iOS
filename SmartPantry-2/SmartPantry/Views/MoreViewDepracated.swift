//
//  MoreView.swift
//  SmartPantry
//
//  Created by Darion Le on 10/29/25.
//
// DEPRACATED CODE, NOT USED IN THE APP

/*
import SwiftUI

struct MoreView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                bigCard(title: "Recipes", subtitle: "Search meals & view details", icon: "fork.knife.circle.fill") {
                    RecipeSearchView()
                }
                bigCard(title: "Favorites", subtitle: "Saved recipes & pantry", icon: "heart.circle.fill") {
                    FavoritesView()
                }
            }
            .padding()
        }
        .navigationTitle("More")
    }

    @ViewBuilder
    private func bigCard<Dest: View>(title: String, subtitle: String, icon: String, @ViewBuilder destination: @escaping () -> Dest) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.accent)
                    .padding(12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .shadow(radius: 2, y: 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.title3.bold())
                    Text(subtitle).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}
*/

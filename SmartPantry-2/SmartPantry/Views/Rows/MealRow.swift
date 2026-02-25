//
//  MealRow.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

struct MealRow: View {
    let meal: MealSummary

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: meal.thumb) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(meal.name)
                .font(.headline)
                .lineLimit(2)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

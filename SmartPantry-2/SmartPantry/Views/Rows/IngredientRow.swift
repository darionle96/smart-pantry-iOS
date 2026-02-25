//
//  IngredientRow.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

struct IngredientRow<Trailing: View>: View {
    let name: String
    let thumbURL: URL?
    @ViewBuilder var trailing: () -> Trailing

    // Initialize a row with no trailing content
    init(name: String, thumbURL: URL?) where Trailing == EmptyView {
        self.name = name
        self.thumbURL = thumbURL
        self.trailing = { EmptyView() }
    }

    // Initialize a row with custom trailing content
    init(name: String, thumbURL: URL?, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.name = name
        self.thumbURL = thumbURL
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: thumbURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(name)
                .font(.headline)

            Spacer()
            trailing()
        }
        .padding(.vertical, 6)
    }
}

//
//  QuantityStepper.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

struct QuantityStepper: View {
    @Binding var value: Int   // Parent control backing storage. Mutating view

    var body: some View {
        HStack(spacing: 12) {
            Button { value = max(0, value - 1) } label: { // Clamp at 0, no negatives
                Image(systemName: "minus.circle.fill")
            }
            .buttonStyle(.plain)
            Text("\(value)")
                .font(.headline)
                .frame(minWidth: 28)
            Button { value += 1 } label: {
                Image(systemName: "plus.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .font(.title3)
        .tint(AppTheme.accent)
    }
}

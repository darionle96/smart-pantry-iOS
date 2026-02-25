//
//  Theme.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import SwiftUI

enum AppTheme {
    // Foodie palette
    static let background = Color(.systemBackground)
    static let surface    = Color(.secondarySystemBackground)

    // Primary accent, Green accent
    static let accent     = Color(red: 0.12, green: 0.65, blue: 0.51)
    static let accentSoft = Color(red: 0.86, green: 0.96, blue: 0.92)
    static let tomato     = Color(red: 0.95, green: 0.45, blue: 0.40)
    static let lemon      = Color(red: 1.00, green: 0.92, blue: 0.60).opacity(0.6)
    static let blueberry  = Color(red: 0.82, green: 0.92, blue: 0.99)

    static let tabBar     = Color(.systemGroupedBackground)    // Explicit tab bar background for consistent styling
}

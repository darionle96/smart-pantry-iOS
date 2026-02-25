//
//  PantryItem.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

struct PantryItem: Identifiable, Codable, Equatable {
    let id: UUID
    var ingredientName: String
    var quantity: Int
    var isChecked: Bool

    init(id: UUID = UUID(), ingredientName: String, quantity: Int = 1, isChecked: Bool = false) { // When quantity 0
        self.id = id
        self.ingredientName = ingredientName
        self.quantity = max(0, quantity)
        self.isChecked = isChecked
    }
}

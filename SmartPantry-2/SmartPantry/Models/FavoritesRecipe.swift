//
//  FavoriteRecipe.swift
//  SmartPantry
//
//  Created by Darion Le on 10/27/25.
//

import Foundation

struct FavoritesRecipe: Identifiable, Codable, Equatable {
    let id: String 
    let name: String
    let thumb: URL?
}

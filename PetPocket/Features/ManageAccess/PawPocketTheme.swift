//
//  PawPocketTheme.swift
//  PetPocket
//
//  Created by Cheisha Amanda on 28/05/26.
//


import SwiftUI

// MARK: - Color Palette Theme
enum PawPocketTheme {
    static let primaryGreen = Color(red: 0.18, green: 0.32, blue: 0.25)
    static let accentOrange = Color(red: 0.91, green: 0.58, blue: 0.37)
    static let backgroundCream = Color(red: 0.984, green: 0.976, blue: 0.973)
    static let cardBackground = Color.white
//    static let cardBackground = Color(red: 0.961, green: 0.953, blue: 0.953)
    static let alertRed = Color(red: 0.85, green: 0.25, blue: 0.25)
    static let textDark = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let textSecondary = Color.secondary
}

// MARK: - Sample Data Model
struct Collaborator: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let isActive: Bool
    let imageName: String
}

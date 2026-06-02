//
//  Color+Extensions.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let r = Double((int >> 16) & 0xFF) / 255
            let g = Double((int >> 8) & 0xFF) / 255
            let b = Double(int & 0xFF) / 255
            self.init(red: r, green: g, blue: b)
        }
    
    // MARK: - Brand: App Background
    static let ppBackground = Color(hex: "#FBF9F8")
    // MARK: - Brand: Greens
    static let ppForestGreen = Color(hex: "#41664F")
    // MARK: - Brand: Grays
    static let ppLightGray = Color(hex: "#F5F3F3")
    // MARK: - Brand: Emergency / Alert
    static let ppEmergencyRed = Color(hex: "#93000A")
    static let ppEmergencyBg  = Color(hex: "#FFDAD6")
    static let ppDietaryBg    = Color(red: 1.00, green: 0.95, blue: 0.95)
    static let ppIconRed = Color(hex: "#93000A")

    // MARK: - Brand: Time Badge
    static let ppTimeBadgeBg = Color(hex: "#FFDCC4")
    static let ppTimeBadgeText = Color(hex: "#2F1400")
}

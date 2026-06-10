//
//  StyleSheet.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

// custom green edge card styling
struct greenEdgeCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .glassEffect(in: .rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.clear))
                    .opacity(0.1)
                    .shadow(color: Color.primaryG, radius: 0, x: -4, y: 0)
            }
    }
}

// login section headers
struct onBoardingSectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .font(.subheadline)
            .foregroundStyle(Color(.primaryG))
    }
}


//
//  ClarifyButtonStyle.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

struct ClarifyButtonStyle: View {
    var action: (() -> Void)? = nil
    @State private var navigate = false
    @Environment(PetDetailStore.self) private var detail

    var body: some View {
        Button(action: {
            if let action {
                action()
            } else {
                navigate = true
            }
        }) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.caption2)
                .fontWeight(.light)
                .frame(width: 26, height: 26)
                .glassEffect()
        }
        .navigationDestination(isPresented: $navigate) {
            ClarifySheetView(pet: detail.pet, isInNavigationStack: true)
        }
    }
}

#Preview {
    ClarifyButtonStyle()
}

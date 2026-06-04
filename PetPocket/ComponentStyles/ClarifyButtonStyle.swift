//
//  ClarifyButtonStyle.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

struct ClarifyButtonStyle: View {
    @State private var navigate = false
    
    var body: some View {
        Button(action: {
            navigate = true
        }) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.caption2)
                .fontWeight(.light)
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .glassEffect(.regular.tint(.brandSecondary.opacity(1)))
//                .background(.accent)
//                .clipShape(Circle())
        }
        .navigationDestination(isPresented: $navigate) {
            ClarifySheetView(isInNavigationStack: true)
        }
    }
}

#Preview {
    ClarifyButtonStyle()
}

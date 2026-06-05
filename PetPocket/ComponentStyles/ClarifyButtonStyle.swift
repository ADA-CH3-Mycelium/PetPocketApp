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
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.caption2)
                .fontWeight(.light)
                .frame(width: 30, height: 30)
                .glassEffect(.regular.tint(.secondaryG.opacity(1)))
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

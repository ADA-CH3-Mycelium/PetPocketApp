//
//  ClarifyButtonStyle.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 02/06/26.
//

import Foundation
import SwiftUI

struct ClarifyButtonStyle: View {
    
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.caption2)
                .fontWeight(.light)
                .frame(width: 26, height: 26)
                .glassEffect(.regular.tint(.secondaryG.opacity(1)))
//                .background(.accent)
//                .clipShape(Circle())
        }
    }
}

#Preview {
    ClarifyButtonStyle()
}

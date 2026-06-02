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
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .glassEffect(.regular.tint(.accentColor))
        }
    }
}

#Preview {
    ClarifyButtonStyle()
}

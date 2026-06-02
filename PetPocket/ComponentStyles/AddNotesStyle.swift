//
//  AddNotesStyle.swift
//  PetPocket
//
//  Created by Michel Pierce on 02/06/26.
//

import Foundation
import SwiftUI

struct AddNotesStyle: View {
    var item: AdditionalNotesCardItem

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("\u{201C}")
                .font(.system(size: 237, weight: .bold, design: .serif))
                .foregroundStyle(Color.primaryG)
                .offset(x: -12, y: 10)
                .opacity(0.15)
            
            Text(item.description)
                .font(.body)
                .italic(true)
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .padding(.top, 110)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: 350, maxHeight: 137)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.separator, lineWidth: 0.5)
        }
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.primaryG, radius: 0, x: -4, y: 0)
        }
    }
}

#Preview {
    AddNotesStyle(
        item: AdditionalNotesCardItem(description: "Oliver will pace at night if his favorite blanket isn't in his crate. Please check the laundry if missing.")
    )
}

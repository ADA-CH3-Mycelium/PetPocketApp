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
                .frame(height:20)
                .font(.system(size: 237, weight: .bold, design: .serif))
                .lineHeight(.loose)
                .foregroundStyle(Color.primaryG)
                .offset(x: -12, y: 98)
                .opacity(0.15)
            
            Text(item.description)
                .italic(true)
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
        .modifier(greenEdgeCard())
    }
}

#Preview {
    AddNotesStyle(
        item: AdditionalNotesCardItem(description: "Oliver will pace at night if his favorite blanket isn't in his crate. Please check the laundry if missing.")
    )
    AddNotesStyle(item: AdditionalNotesCardItem(description: "need to do tricks before meal."))
}

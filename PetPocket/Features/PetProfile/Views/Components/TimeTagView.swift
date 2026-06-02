//
//  TimeTagView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

struct TimeTagView: View {
    let time: String

    var body: some View {
        Text(time)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.ppTimeBadgeText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.ppTimeBadgeBg)
            .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 8) {
        TimeTagView(time: "8:00 AM")
        TimeTagView(time: "1:00 PM")
        TimeTagView(time: "7:00 PM")
    }
    .padding()
}

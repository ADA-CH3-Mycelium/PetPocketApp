//
//  PetProfileStyles.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import Foundation
import SwiftUI

// MARK: - PET PROFILE VIEW

// VAR
var catItem: [CategoryItem2] = [
    // FOOD
    CategoryItem2(
        icon: "fork.knife",
        label: "Food",
        isActive: false,
        isAlert: false,
        targetScreen: .food
    ),
    // WASTE
    CategoryItem2(
        icon: "leaf.fill",
        label: "Waste",
        isActive: false,
        isAlert: false,
        targetScreen: .waste
    ),
    // CARE
    CategoryItem2(
        icon: "heart.text.square.fill",
        label: "Care Notes",
        isActive: false,
        isAlert: false,
        targetScreen: .care
    ),
    // EMERGENCY
    CategoryItem2(
        icon: "exclamationmark.shield.fill",
        label: "Emergency",
        isActive: false,
        isAlert: true,
        targetScreen: .emergency
    )
    ]

struct TwCoColGrid: View {
    var catItem: [CategoryItem2]
    var onTap: (ScreenViews) -> Void
    let cols = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 20) {
            ForEach(catItem, id: \.self) { item in
                Button(action: { onTap(item.targetScreen) }) {
                    ZStack {
                        //Color.secondaryG.opacity(1)

                        Image(systemName: item.icon)
                            .font(.system(size: 80))
                            .foregroundColor(Color.primaryG.opacity(0.2))
                            .offset(x: 65, y: 25)

                        Text(item.label)
                            .font(.headline)
                            .foregroundColor(.primary)

                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glassEffect(
                        .regular.tint(Color.secondaryG.opacity(1)),
                        in: .rect(cornerRadius: 16)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
//
//#Preview {
//    ZStack {
//        Color.background.ignoresSafeArea()
//        TwCoColGrid(catItem: catItem)
//    }
//}

// MARK: - Category Page Headers

struct CategoryHeader: View {
    let item: CategoryHeaderItem
    
    
    var body: some View {
        HStack(spacing: 2) {
            //Image(systemName: item.icon)
            Text(item.label)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
        }
    }
}

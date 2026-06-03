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

// TWO COL GRID
struct TwCoColGrid: View {
    var catItem: [CategoryItem2]
    let cols = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {

        LazyVGrid(columns: cols, spacing: 20) {
            ForEach(catItem, id: \.self) { item in
                // colour
//                let col = item.isAlert ? Color.alertRed : Color.primaryG
                NavigationLink(value: item.targetScreen) {
                    ZStack() {
                        //Color.black.opacity(0.2)
                        RadialGradient(
                            gradient: Gradient(colors: [Color.primaryG, .clear]),
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 300
                                               
                        ).opacity(0.95)

                        // icon
                        Image(systemName: item.icon)
                            .font(.system(size: 80))
                            .foregroundColor(Color.primaryG.opacity(0.5))
                            .blendMode(.hardLight)
                            .offset(x: 70, y: 25)
                        
                        // text label
                        Text(item.label)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glassEffect(
                        in: .rect(cornerRadius: 16)
                    )

                }
            }

        }.navigationDestination(for: ScreenViews.self) { screen in
            switch screen {
            case .food:
                FoodView()
            case .waste:
                WasteView()
            case .care:
                CareView()
            case .emergency:
                EmergencyView()
            }

        }

    }

}

#Preview {
    ZStack {
        Color.background.ignoresSafeArea()
        TwCoColGrid(catItem: catItem)
    }
}

// MARK: - Category Page Headers

struct CategoryHeader: View {
    let item: CategoryHeaderItem
    
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: item.icon)
            Text(item.label)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
        }
    }
}

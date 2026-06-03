//
//  PetProfileStyles.swift
//  PetPocket
//
//  Created by Samantha Joice Lugay on 01/06/26.
//

import Foundation
import SwiftUI

// MARK: - PET PROFILE VIEW

// TWO COL GRID
struct TwCoColGrid: View {
    @Binding var catItem: [CategoryItem2]
    let cols = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {

        LazyVGrid(columns: cols, spacing: 20) {
            ForEach(catItem, id: \.self) { item in
                let col = item.isAlert ? Color.alertRed : Color.primaryG
                NavigationLink(value: item.targetScreen) {
                    ZStack( /*spacing: 10*/) {
                        Text(item.label)
                            .font(.body)
                            .foregroundColor(
                                item.isAlert
                                    ? Color.alertRed
                                    : .primary
                            )

                        Image(systemName: item.icon)
                            .font(.largeTitle)
                            .foregroundColor(col.opacity(0.75))
                            .offset(x: 65, y: 25)

                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glassEffect(
                        .regular.tint(col.opacity(0.10)),
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

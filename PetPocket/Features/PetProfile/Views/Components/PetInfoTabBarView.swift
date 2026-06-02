//
//  PetInfoTabBarView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

// MARK: - Tab Enum
enum PetInfoTab: CaseIterable, Hashable {
    case food, waste, careNotes, emergency

    var title: String {
        switch self {
        case .food: return "Food"
        case .waste: return "Waste"
        case .careNotes: return "Care Notes"
        case .emergency: return "Emergency"
        }
    }

    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .waste: return "leaf.fill"
        case .careNotes: return "list.clipboard.fill"
        case .emergency: return "light.beacon.max.fill"
        }
    }


    var selectedBackground: Color {
        switch self {
        case .food: return .ppForestGreen
        case .waste: return .ppForestGreen
        case .careNotes: return .ppForestGreen
        case .emergency: return .ppEmergencyBg
        }
    }


    var selectedIconColor: Color {
        switch self {
        case .food: return .white
        case .waste: return .primary
        case .careNotes: return .primary
        case .emergency: return .ppEmergencyRed
        }
    }


    var selectedLabelColor: Color {
        switch self {
        case .emergency: return .ppEmergencyRed
        default: return .primary
        }
    }
}

// MARK: - Tab Bar
struct PetInfoTabBarView: View {
    @Binding var selectedTab: PetInfoTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PetInfoTab.allCases, id: \.self) { tab in
                PetInfoTabItem(tab: tab, isSelected: selectedTab == tab)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
            }
        }
    }
}

// MARK: - Single Tab Item (private)
private struct PetInfoTabItem: View {
    let tab: PetInfoTab
    let isSelected: Bool
    private var isEmergency: Bool { tab == .emergency }

    var body: some View {
        VStack(spacing: 6) {

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected || isEmergency ? tab.selectedBackground : Color(.white))
                    .frame(width: 62, height: 62)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: tab.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(
                        isSelected
                            ? tab.selectedIconColor
                            : Color(.label).opacity(0.55)
                    )
            }


            Text(tab.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(
                    isEmergency
                        ? .ppEmergencyRed
                        : (isSelected ? tab.selectedLabelColor : .secondary)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedTab: PetInfoTab = .food
    PetInfoTabBarView(selectedTab: $selectedTab)
        .padding()
}

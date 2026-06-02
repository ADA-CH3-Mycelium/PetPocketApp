//
//  FeedingRoutineCard.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI

struct FeedingRoutineCard: View {
    let meal: FeedingMeal2

    @State private var swipeOffset: CGFloat = 0
    @State private var showClarify = false

    private let buttonWidth: CGFloat = 90
    private let swipeThreshold: CGFloat = 50

    var body: some View {
        ZStack(alignment: .leading) {

            ClarifySwipeButton {
                withAnimation(.spring(response: 0.3)) { swipeOffset = 0 }
                showClarify = true
            }
            .frame(width: buttonWidth)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.trailing, 8)
	
            cardBody
                .offset(x: swipeOffset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            guard value.translation.width > 0,
                                  abs(value.translation.width) > abs(value.translation.height)
                            else { return }
                            swipeOffset = min(value.translation.width, buttonWidth)
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                swipeOffset = value.translation.width > swipeThreshold
                                    ? buttonWidth
                                    : 0
                            }
                        }
                )
        }
        .sheet(isPresented: $showClarify) {
            ClarifySheetView(mealName: meal.mealName)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
        }
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image(systemName: meal.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.ppForestGreen)
                Spacer()
                TimeTagView(time: meal.time)
            }

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.mealName)
                        .font(.headline).fontWeight(.bold)
                    Text(meal.amount)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.ppForestGreen)
                    Text(meal.notes)
                        .font(.caption).foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let media = meal.media {
                    Spacer()
                    MediaThumbnailView(media: media)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        FeedingRoutineCard(meal: Pet2.sampleCooper.feedingMeals[0])
        FeedingRoutineCard(meal: Pet2.sampleCooper.feedingMeals[1])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

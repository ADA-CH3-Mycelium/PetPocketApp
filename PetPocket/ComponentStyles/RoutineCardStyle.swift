//
//  RoutineCardStyle.swift
//  PetPocket
//
//  Created by Samantha Lugay on 01/06/26.
//

import SwiftUI

// MARK: - 2. Mock Data
let mockData: [RoutineCardItem] = [
    RoutineCardItem(
        title: "Breakfast",
        time: "8:00",
        description:
            "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
        icon: "sunrise.fill",
        media: MediaAttachment.photo("testphoto")
    ),
    RoutineCardItem(
        title: "Lunch",
        time: "12:00",
        description:
            "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
        icon: "sun.max.fill",
        media: MediaAttachment.photo("testphoto")
    ),
    RoutineCardItem(
        title: "Dinner",
        time: "18:00",
        description:
            "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
        icon: "sunset.fill",
        media: nil
    ),
    RoutineCardItem(
        title: "Every 4 Hour",
        time: "",
        description:
            "Consistent timing prevents accidents and builds bladder control.",
        icon: "clock.fill",
        media: nil
    ),
    RoutineCardItem(
        title: "Backyard",
        time: "",
        description: "Familiar scents help Cooper focus on the task quickly.",
        icon: "location.north.fill",
        media: nil
    ),
    RoutineCardItem(
        title: "Cleaning",
        time: "",
        description: "Biodegradable bags in side pocket.",
        icon: "bubbles.and.sparkles.fill",
        media: nil
    ),
    RoutineCardItem(
        title: "Critical Medication",
        time: "July 1st",
        description: "Heartworm pill on 1st of every month.",
        icon: "pill.fill",
        media: nil
    ),
    RoutineCardItem(
        title: "Fear Triggers",
        time: "",
        description: "Thunderstorms and Fireworks cause severe anxiety.",
        icon: "bolt.fill",
        media: nil
    ),
]

// MARK: - 3. Card Component View
struct RoutineCard: View {
    // reading environment colour mode
    @Environment(\.colorScheme) var colorScheme

    @State private var showClarifySheet = false
    @Environment(PetDetailStore.self) private var detail

    let item: RoutineCardItem
    let isEmergency: Bool

    var body: some View {
        HStack(alignment: .top) {
            // left
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 2) {
                    Image(systemName: item.icon)
                        .font(.caption)

                    Text(
                        item.time.isEmpty
                            ? item.title : "\(item.title) • \(item.time)"
                    )
                    .font(.headline)
                    .fontWeight(.bold)

                }.foregroundColor(Color.primaryG)

                Text(item.description)
                    .font(.body)

            }

            Spacer(minLength: 7)
            // right
            VStack(alignment: .trailing, spacing: 7) {
                // media
                if item.media != nil {
                    if let media = item.media {
                        MediaThumbnailView(media: media)
                    }
                }

//                // clarify btn
//                if isEmergency != true {
//                    ClarifyButtonStyle(action: { showClarifySheet = true })
//                        .offset(y: 2)
//                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .modifier(greenEdgeCard())
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .glassEffect(
//            in: .rect(cornerRadius: 16)
//        )
        .sheet(isPresented: $showClarifySheet) {
            ClarifySheetView(pet: detail.pet, routineTitle: item.title)
        }
    }
}
// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        RoutineCard(item: mockData[0], isEmergency: false)
        RoutineCard(item: mockData[3], isEmergency: false)
        RoutineCard(item: mockData[5], isEmergency: false)
        RoutineCard(item: mockData[7], isEmergency: false)
    }
    .padding()
    .background(Color.background)
}

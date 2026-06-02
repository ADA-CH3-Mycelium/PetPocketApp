//
//  RoutineCardStyle.swift
//  PetPocket
//
//  Created by Samantha Lugay on 01/06/26.
//

import SwiftUI

// mock data
let mockData : [RoutineCardItem] = [
    RoutineCardItem(title: "Breakfast",
                    time: "8:00",
                    description: "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
                    icon: "sunrise.fill",
                    media: MediaAttachment.photo("testphoto")),
    RoutineCardItem(title: "Lunch",
                    time: "12:00",
                    description: "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
                    icon: "sun.max.fill",
                    media: MediaAttachment.photo("testphoto")),
    RoutineCardItem(title: "Dinner",
                    time: "18:00",
                    description: "1 Cup Dry Kibble. Mix with warm water to soften the grains. Add probiotic powder.",
                    icon: "sunset.fill",
                    media: nil)
]

struct RoutineCard: View {
    
    let item: RoutineCardItem
    
    var body: some View {
            HStack() {
                //LEFT
                VStack(alignment: .leading, spacing: 5) {
                    HStack() {
                        
                        Image(systemName: item.icon)
                            .font(.caption)
                        
                        Text(item.title + " • " + item.time)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                    } .foregroundColor(Color.primaryG)
                    
                    Text(item.description)
                        .font(.body)
                    }
                
                Spacer()
                
                // RIGHT
                VStack(alignment: .trailing, spacing: 5) {
                    // is there media
                    if item.media != nil {
                        if let media = item.media {
                            MediaThumbnailView(media: media)
                        }
                    }
                    //clarify button 
                    ClarifyButtonStyle()
                    
                }
            }
            .padding(20)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glassEffect(.regular.tint(.accent.opacity(0.01)),
                         in: .rect(cornerRadius: 16))
        }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        RoutineCard(item: mockData[0])
        RoutineCard(item: mockData[1])
        RoutineCard(item: mockData[2])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

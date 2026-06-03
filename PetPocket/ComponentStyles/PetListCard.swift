//
//  OwnedPetCard.swift
//  PetPocket
//
//  Created by Michel Pierce on 02/06/26.
//

import SwiftUI

struct PetListCard: View {
    let item: PetItem
    
    var body: some View {
        VStack(spacing: 0) {
            // Pet image
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.55),
                            .init(color: .clear, location: 1),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Bottom info row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if case .sitting(_, _, let dateRange) = item.type {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(dateRange)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                switch item.type {
                case .owning:
                    Text("Your Pet")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                    
                case .sitting(let sitter, let sitterImage, _):
                    HStack(spacing: 6) {
                        Image(sitterImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                        
                        Text(sitter)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    PetListCard(item: PetItem(
        id: UUID(),
        name: "Cooper",
        gender: "Male",
        age: "3",
        breed: "Golden Retriever",
        image: "1PetImage",
        type: .owning
    ))
}

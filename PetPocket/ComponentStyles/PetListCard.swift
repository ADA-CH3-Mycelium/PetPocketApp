//
//  PetListCard.swift
//  PetPocket
//
//  Created by Michel Pierce on 02/06/26.
//

import SwiftUI

struct PetListCard: View {
    let item: PetItem
    
    var body: some View {
        VStack(spacing: 0) {
            // Pet image — loads from Supabase Storage URL, falls back to placeholder
            petImage
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
                    
                    if case .sitting(_, _, let dateRange) = item.type, !dateRange.isEmpty {
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
                        if sitterImage.isEmpty {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.secondary)
                        } else {
                            Image(sitterImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 22, height: 22)
                                .clipShape(Circle())
                        }
                        
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

    @ViewBuilder
    private var petImage: some View {
//        if let urlString = item.photoUrl, let url = URL(string: urlString) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable()
//                case .failure, .empty:
//                    photoPlaceholder
//                @unknown default:
//                    photoPlaceholder
//                }
//            }
//        } else {
            photoPlaceholder
        //}
    }

    private var photoPlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay(
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(.systemGray3))
            )
    }
}

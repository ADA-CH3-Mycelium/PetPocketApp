//
//  PhotoFullScreenView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//
import SwiftUI

struct PhotoFullScreenView: View {
    let imageName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.black.opacity(0.4))
                    .padding(16)
            }
        }
    }
}

// Full-screen viewer for a remote image URL (Supabase Storage).
struct PhotoURLFullScreenView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                default:
                    ProgressView().tint(.white)
                }
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.black.opacity(0.4))
                    .padding(16)
            }
        }
    }
}

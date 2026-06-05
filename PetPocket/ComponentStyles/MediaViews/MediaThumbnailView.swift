//
//  MediaThumbnailView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI
import AVKit

struct MediaThumbnailView: View {
    let media: MediaAttachment

    @State private var showFullScreen = false
    @State private var videoThumbnail: UIImage? = nil

    var body: some View {
        ZStack {
            Group {
                switch media {
                case .photo(let name):
                    Image(name)
                        .resizable()
                        .scaledToFill()
                case .video:
                    if let thumbnail = videoThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.black.opacity(0.6)
                    }
                }
            }

            if case .video = media {
                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .offset(x: 1)
                    )
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onTapGesture {
            showFullScreen = true
        }
        .task {
            if case .video(let url) = media {
                videoThumbnail = await makeThumbnail(from: url)
            }
        }

        .fullScreenCover(isPresented: $showFullScreen) {
            switch media {
            case .photo(let name):
                PhotoFullScreenView(imageName: name)
            case .video(let url):
                VideoFullScreenView(url: url)
            }
        }
    }		

    private func makeThumbnail(from url: URL) async -> UIImage? {
        await Task.detached(priority: .background) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
            return UIImage(cgImage: cgImage)
        }.value
    }
}

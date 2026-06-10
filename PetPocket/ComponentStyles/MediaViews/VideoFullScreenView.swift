//
//  VideoFullScreenView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI
import AVKit

struct VideoFullScreenView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    @State private var player: AVPlayer
    @StateObject private var captionController = CaptionController()

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()

            VStack {
                Spacer()
                if captionController.isCaptionsEnabled && !captionController.caption.isEmpty {
                    Text(captionController.caption)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(.bottom, 80)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: captionController.caption)
            .padding(.horizontal, 24)
            .ignoresSafeArea(.keyboard)

            // Debug status overlay
            VStack {
                HStack {
                    Text("CC Debug: \(captionController.debugStatus)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(6)
                        .padding(.leading, 16)
                        .padding(.top, 16)
                    Spacer()
                }
                Spacer()
            }

            HStack(spacing: 16) {
                if captionController.isAuthorised && captionController.isAvailable {
                    Button {
                        captionController.isCaptionsEnabled.toggle()
                    } label: {
                        Image(systemName: captionController.isCaptionsEnabled ? "captions.bubble.fill" : "captions.bubble")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }

                Button {
                    player.pause()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.white, Color.black.opacity(0.4))
                }
            }
            .padding(16)
        }
        .onAppear {
            player.play()
            captionController.attach(player: player, videoURL: url)
            captionController.requestPermissions()
        }
        .onDisappear {
            player.pause()
            captionController.detach()
        }
    }
}

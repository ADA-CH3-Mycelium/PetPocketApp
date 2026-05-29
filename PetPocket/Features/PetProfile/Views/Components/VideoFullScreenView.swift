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

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()


            Button {
                player.pause()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.black.opacity(0.4))
                    .padding(16)
            }
        }
        .onAppear { player.play() }
        .onDisappear { player.pause() }
    }
}

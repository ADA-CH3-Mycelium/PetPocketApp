//
//  VideoFullScreenView.swift
//  PetPocket
//
//  Created by Naufal Muafa on 28/05/26.
//

import SwiftUI
import AVKit

/// AVPlayerViewController with native controls OFF — removes the system control
/// bar (and with it AirPlay + the volume slider). All controls are custom below.
private struct PlayerLayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        vc.allowsPictureInPicturePlayback = false
        vc.videoGravity = .resizeAspect
        return vc
    }

    func updateUIViewController(_ vc: AVPlayerViewController, context: Context) {}
}

struct VideoFullScreenView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    @State private var player: AVPlayer
    @StateObject private var captionController = CaptionController()

    // Custom controls share the system show/hide behavior: tap video to reveal,
    // tap again (or auto-timeout) to hide.
    @State private var controlsVisible = true
    @State private var hideWorkItem: DispatchWorkItem?

    @State private var isPlaying = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isScrubbing = false
    @State private var timeObserver: Any?

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            PlayerLayerView(player: player)
                .ignoresSafeArea()

            // Captions (always visible, independent of controls).
            VStack {
                Spacer()
                if !captionController.caption.isEmpty {
                    Text(captionController.caption)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.bottom, 110)
                        .transition(.opacity)
                }
            }
            .id(captionController.caption)
            .animation(.easeInOut, value: captionController.caption)
            .padding(.horizontal, 24)
            .ignoresSafeArea(.keyboard)

            // Custom controls overlay.
            controlsOverlay
                .opacity(controlsVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: controlsVisible)
        }
        .contentShape(Rectangle())
        .onTapGesture { toggleControls() }
        .onAppear {
            player.play()
            captionController.isCaptionsEnabled = true
            captionController.attach(player: player, videoURL: url)
            captionController.requestPermissions()
            addTimeObserver()
            scheduleAutoHide()
        }
        .onDisappear {
            player.pause()
            captionController.detach()
            hideWorkItem?.cancel()
            removeTimeObserver()
        }
    }

    // MARK: - Controls

    private var controlsOverlay: some View {
        VStack {
            // Top-right: CC + close.
            HStack(spacing: 16) {
                Spacer()
                if captionController.isAuthorised {
                    Button {
                        captionController.isCaptionsEnabled.toggle()
                        scheduleAutoHide()
                    } label: {
                        Image(systemName: captionController.isCaptionsEnabled ? "captions.bubble.fill" : "captions.bubble")
                            .font(.system(size: 26))
                            .foregroundColor(captionController.isAvailable ? .white : .white.opacity(0.6))
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

            Spacer()

            // Center: play/pause.
            Button {
                togglePlayPause()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                    .shadow(radius: 6)
            }

            Spacer()

            // Bottom: scrubber + times.
            HStack(spacing: 12) {
                Text(timeString(currentTime))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)

                Slider(
                    value: $currentTime,
                    in: 0...(max(duration, 0.1)),
                    onEditingChanged: { editing in
                        isScrubbing = editing
                        if editing {
                            hideWorkItem?.cancel()
                        } else {
                            seek(to: currentTime)
                            scheduleAutoHide()
                        }
                    }
                )
                .tint(.white)

                Text(timeString(duration))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }

    private func togglePlayPause() {
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
        scheduleAutoHide()
    }

    private func seek(to seconds: Double) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    // MARK: - Time observing

    private func addTimeObserver() {
        if let item = player.currentItem {
            let d = item.asset.duration.seconds
            if d.isFinite { duration = d }
        }
        let interval = CMTime(seconds: 0.3, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            if duration <= 0.1, let d = player.currentItem?.duration.seconds, d.isFinite {
                duration = d
            }
            if !isScrubbing { currentTime = time.seconds }
        }
    }

    private func removeTimeObserver() {
        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }
    }

    // MARK: - Controls visibility

    private func toggleControls() {
        controlsVisible.toggle()
        if controlsVisible { scheduleAutoHide() } else { hideWorkItem?.cancel() }
    }

    private func scheduleAutoHide() {
        hideWorkItem?.cancel()
        let item = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) { controlsVisible = false }
        }
        hideWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: item)
    }

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

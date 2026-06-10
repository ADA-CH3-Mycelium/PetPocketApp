//
//  CaptionController.swift
//  PetPocket
//
//  Created by Naufal Muafa on 10/06/26.
//

import AVFoundation
import Speech
import Combine

struct CaptionSegment {
    let text: String
    let start: TimeInterval
    let end: TimeInterval
}

/// Transcribes a video URL exactly once and caches the result, independent of
/// any view's lifecycle. The full-screen player view can be torn down and
/// recreated (SwiftUI re-presents the cover, AVPlayer churns) without losing or
/// cancelling the in-flight download/transcription — the next CaptionController
/// for the same URL just awaits the same task and reuses the cache.
@MainActor
final class CaptionStore {
    static let shared = CaptionStore()

    private var cache: [URL: [CaptionSegment]] = [:]
    private var inFlight: [URL: Task<[CaptionSegment], Never>] = [:]

    func segments(for url: URL) async -> [CaptionSegment] {
        if let cached = cache[url] { return cached }
        if let task = inFlight[url] { return await task.value }

        let task = Task { await Self.transcribe(url) }
        inFlight[url] = task
        let result = await task.value
        cache[url] = result
        inFlight[url] = nil
        return result
    }

    /// Captions are always generated in English (en-US), regardless of device locale.
    nonisolated private static func transcribe(_ url: URL) async -> [CaptionSegment] {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("Caption: speech not authorized"); return []
        }
        guard let recogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US")),
              recogniser.isAvailable else {
            print("Caption: en-US recognizer unavailable"); return []
        }

        // Speech URL requests require a local file — download remote clips first.
        let localURL: URL
        if url.isFileURL {
            localURL = url
        } else {
            do {
                let (tmp, _) = try await URLSession.shared.download(from: url)
                let dest = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(UUID().uuidString + ".mov")
                try FileManager.default.moveItem(at: tmp, to: dest)
                localURL = dest
                print("Caption: clip cached at \(dest.lastPathComponent)")
            } catch {
                print("Caption: download failed: \(error.localizedDescription)")
                return []
            }
        }

        let request = SFSpeechURLRecognitionRequest(url: localURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = recogniser.supportsOnDeviceRecognition

        let segments: [CaptionSegment] = await withCheckedContinuation { cont in
            let lock = NSLock()
            var resumed = false
            var task: SFSpeechRecognitionTask?
            func finish(_ segs: [CaptionSegment]) {
                lock.lock(); defer { lock.unlock() }
                if resumed { return }
                resumed = true
                cont.resume(returning: segs)
            }
            task = recogniser.recognitionTask(with: request) { result, error in
                _ = task   // retain the task until the callback fires
                if let result = result, result.isFinal {
                    finish(result.bestTranscription.segments.map {
                        CaptionSegment(text: $0.substring,
                                       start: $0.timestamp,
                                       end: $0.timestamp + $0.duration)
                    })
                } else if error != nil {
                    finish([])
                }
            }
        }
        print("Caption: transcribed \(segments.count) words")
        return segments
    }
}

/// Owns one player's caption display: asks `CaptionStore` for the transcript,
/// then a light timer maps `player.currentTime` onto the timed segments.
/// No AVAudioSession changes, no audio engine — video playback is untouched.
@MainActor
final class CaptionController: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var caption: String = ""
    @Published var isAvailable: Bool = false
    @Published var isAuthorised: Bool = false
    @Published var debugStatus: String = "Initialized"
    @Published var isCaptionsEnabled: Bool = true {
        didSet {
            debugStatus = "CC Toggled: \(isCaptionsEnabled)"
            if isCaptionsEnabled { startSession() } else { stopSession() }
        }
    }

    private var player: AVPlayer?
    private var videoURL: URL?
    private var recogniser: SFSpeechRecognizer?
    private var segments: [CaptionSegment] = []
    private var fullTranscript: String = ""
    private var syncTimer: Timer?
    private var started = false

    override init() {
        super.init()
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        self.recogniser = speechRecognizer
        self.isAvailable = speechRecognizer?.isAvailable ?? false
        speechRecognizer?.delegate = self
        debugStatus = "Init: en-US available=\(isAvailable)"
        print("CaptionController initialized. en-US available: \(isAvailable)")
    }

    func attach(player: AVPlayer, videoURL: URL) {
        self.player = player
        self.videoURL = videoURL
        checkPermissions()
        print("CaptionController attached. URL: \(videoURL.absoluteString)")
        if isCaptionsEnabled && isAuthorised { startSession() }
    }

    func detach() {
        stopSession()
        self.player = nil
        self.videoURL = nil
        print("CaptionController detached")
    }

    // MARK: - Permissions (file transcription needs Speech only, not mic)

    func checkPermissions() {
        let speechAuth = SFSpeechRecognizer.authorizationStatus()
        isAuthorised = speechAuth == .authorized
        isAvailable = isAuthorised && (recogniser?.isAvailable ?? false)
        debugStatus = "Perms: speech=\(speechAuth.rawValue), auth=\(isAuthorised)"
    }

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAuthorised = status == .authorized
                self.isAvailable = self.isAuthorised && (self.recogniser?.isAvailable ?? false)
                self.debugStatus = "Perm result: auth=\(self.isAuthorised)"
                if self.isCaptionsEnabled {
                    if self.isAuthorised { self.startSession() }
                    else { self.isCaptionsEnabled = false }
                }
            }
        }
    }

    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in self.isAvailable = available && self.isAuthorised }
    }

    // MARK: - Session

    private func startSession() {
        guard isAuthorised else { requestPermissions(); return }
        guard !started, let url = videoURL else { return }
        started = true
        debugStatus = "Loading transcript..."
        print("Starting caption session")

        Task {
            // CaptionStore survives view teardown; download/transcribe won't be cancelled.
            let segs = await CaptionStore.shared.segments(for: url)
            guard self.started else { return }   // view closed while loading
            self.segments = segs
            self.fullTranscript = segs.map { $0.text }.joined(separator: " ")
            self.debugStatus = segs.isEmpty ? "No speech detected" : "Got \(segs.count) words"
            self.startSyncTimer()
        }
    }

    private func stopSession() {
        started = false
        syncTimer?.invalidate()
        syncTimer = nil
        segments = []
        fullTranscript = ""
        caption = ""
        debugStatus = "Stopped"
    }

    private func startSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.updateCaption() }
        }
    }

    private func updateCaption() {
        guard let player = player, !segments.isEmpty else { return }
        let t = player.currentTime().seconds

        // Some recognizers emit zero timestamps; then just show the whole transcript.
        let hasTiming = segments.contains { $0.start > 0 || $0.end > 0 }
        if !hasTiming { caption = fullTranscript; return }

        let window = segments.filter { $0.start <= t && $0.end >= t - 4.0 }
        caption = window.map { $0.text }.joined(separator: " ")
    }
}

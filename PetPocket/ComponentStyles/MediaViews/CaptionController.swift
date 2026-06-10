//
//  CaptionController.swift
//  PetPocket
//
//  Created by Naufal Muafa on 10/06/26.
//

import AVFoundation
import Speech
import Combine

@MainActor
final class CaptionController: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var caption: String = ""
    @Published var isAvailable: Bool = false
    @Published var isAuthorised: Bool = false
    @Published var debugStatus: String = "Initialized"
    @Published var isCaptionsEnabled: Bool = false {
        didSet {
            print("CC Toggled: \(isCaptionsEnabled)")
            debugStatus = "CC Toggled: \(isCaptionsEnabled)"
            if isCaptionsEnabled {
                if tempLocalURL != nil {
                    startSession()
                } else if downloadTask == nil {
                    startDownload()
                }
            } else {
                stopSession()
            }
        }
    }

    private var player: AVPlayer?
    private var videoURL: URL?
    private var recogniser: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var assetReader: AVAssetReader?
    private var readerOutput: AVAssetReaderTrackOutput?
    private var pendingBuffer: CMSampleBuffer?
    
    private var timer: Timer?
    private var silenceTimer: Timer?
    private var restartTimer: Timer?
    
    private var lastPolledTime: CMTime = .zero
    private var tempLocalURL: URL?
    private var downloadTask: Task<Void, Never>?
    private var activeRecognitionTaskSetup: Task<Void, Never>?
    
    override init() {
        super.init()
        let locale = Locale.current
        let speechRecognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        self.recogniser = speechRecognizer
        self.isAvailable = speechRecognizer?.isAvailable ?? false
        speechRecognizer?.delegate = self
        debugStatus = "Init: Speech locale=\(locale.identifier), available=\(isAvailable)"
        print("CaptionController initialized. Speech recognizer locale: \(locale.identifier), available: \(isAvailable)")
    }
    
    deinit {
        let path = tempLocalURL
        Task.detached {
            if let path = path {
                try? FileManager.default.removeItem(at: path)
            }
        }
    }
    
    func attach(player: AVPlayer, videoURL: URL) {
        self.player = player
        self.videoURL = videoURL
        checkPermissions()
        print("CaptionController attached to player with URL: \(videoURL.absoluteString)")
    }
    
    func detach() {
        downloadTask?.cancel()
        downloadTask = nil
        activeRecognitionTaskSetup?.cancel()
        activeRecognitionTaskSetup = nil
        stopSession()
        self.player = nil
        self.videoURL = nil
        if let path = tempLocalURL {
            try? FileManager.default.removeItem(at: path)
            tempLocalURL = nil
        }
        print("CaptionController detached")
    }
    
    func checkPermissions() {
        let speechAuth = SFSpeechRecognizer.authorizationStatus()
        let micAuthGranted: Bool
        
        if #available(iOS 17.0, *) {
            micAuthGranted = AVAudioApplication.shared.recordPermission == .granted
        } else {
            micAuthGranted = AVAudioSession.sharedInstance().recordPermission == .granted
        }
        
        if speechAuth == .authorized && micAuthGranted {
            self.isAuthorised = true
            self.isAvailable = self.recogniser?.isAvailable ?? false
        } else {
            self.isAuthorised = false
        }
        debugStatus = "Perms: speech=\(speechAuth.rawValue), mic=\(micAuthGranted), auth=\(isAuthorised)"
        print("Permission check: speech=\(speechAuth.rawValue), mic=\(micAuthGranted), isAuthorised=\(isAuthorised), isAvailable=\(isAvailable)")
    }
    
    func requestPermissions() {
        debugStatus = "Requesting permissions..."
        print("Requesting speech and microphone permissions...")
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if #available(iOS 17.0, *) {
                    AVAudioApplication.requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            self?.handlePermissionResult(speechGranted: status == .authorized, micGranted: granted)
                        }
                    }
                } else {
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            self?.handlePermissionResult(speechGranted: status == .authorized, micGranted: granted)
                        }
                    }
                }
            }
        }
    }
    
    private func handlePermissionResult(speechGranted: Bool, micGranted: Bool) {
        self.isAuthorised = speechGranted && micGranted
        self.isAvailable = (self.recogniser?.isAvailable ?? false) && self.isAuthorised
        debugStatus = "Perm result: auth=\(isAuthorised), avail=\(isAvailable)"
        print("Permissions result: speechGranted=\(speechGranted), micGranted=\(micGranted), isAuthorised=\(isAuthorised)")
        
        if self.isCaptionsEnabled {
            if self.isAuthorised && self.isAvailable {
                if tempLocalURL != nil {
                    startSession()
                } else if downloadTask == nil {
                    startDownload()
                }
            } else {
                self.isCaptionsEnabled = false
            }
        }
    }
    
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            self.isAvailable = available && self.isAuthorised
            debugStatus = "Speech availability change: \(available)"
            print("Speech recognizer availability changed to: \(available), isAvailable now: \(isAvailable)")
            if !available {
                self.isCaptionsEnabled = false
            }
        }
    }
    
    private func startDownload() {
        guard let videoURL = videoURL else { return }
        debugStatus = "Starting download/copy..."
        print("Starting video copy/download task...")
        
        downloadTask = Task {
            if let localURL = await downloadVideo(from: videoURL) {
                self.tempLocalURL = localURL
                if self.isCaptionsEnabled {
                    self.startSession()
                }
            }
            self.downloadTask = nil
        }
    }
    
    private func startSession() {
        guard isAuthorised && isAvailable else {
            requestPermissions()
            return
        }
        
        // Configure AVAudioSession for playAndRecord to enable Speech framework engine
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            debugStatus = "AVAudioSession playAndRecord activated"
            print("AVAudioSession configured to .playAndRecord and activated")
        } catch {
            debugStatus = "AVAudioSession config failed: \(error.localizedDescription)"
            print("Failed to configure AVAudioSession for captions: \(error.localizedDescription)")
        }
        
        guard let player = player else { return }
        let currentTime = player.currentTime()
        debugStatus = "Starting session at \(Int(currentTime.seconds))s"
        print("Starting CC session at player time: \(currentTime.seconds)")
        
        activeRecognitionTaskSetup?.cancel()
        activeRecognitionTaskSetup = Task {
            await startRecognitionTask(from: currentTime)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.pollAudioBuffer()
            }
        }
        
        restartTimer?.invalidate()
        restartTimer = Timer.scheduledTimer(withTimeInterval: 50.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.restartRecognitionTask()
            }
        }
    }
    
    private func stopSession() {
        debugStatus = "Stopping session"
        print("Stopping CC session...")
        timer?.invalidate()
        timer = nil
        restartTimer?.invalidate()
        restartTimer = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        cleanupReaderAndRecognition()
        caption = ""
        
        // Deactivate AVAudioSession and restore category to playback
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            try session.setCategory(.playback, mode: .default, options: [])
            print("AVAudioSession deactivated and restored to .playback")
        } catch {
            print("Failed to clean up AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func startRecognitionTask(from startTime: CMTime) async {
        guard let localURL = tempLocalURL else { return }
        cleanupReaderAndRecognition()
        
        guard let recogniser = recogniser, recogniser.isAvailable else {
            debugStatus = "Speech recognizer unavailable"
            print("Speech recognizer is not available for transcription task")
            return
        }
        
        let asset = AVURLAsset(url: localURL)
        debugStatus = "Loading asset tracks..."
        print("Initializing AVAssetReader for speech recognition task...")
        
        do {
            let tracks = try await asset.loadTracks(withMediaType: .audio)
            try Task.checkCancellation()
            
            guard let audioTrack = tracks.first else {
                debugStatus = "Error: No audio track found"
                print("No audio track found in asset for captions")
                return
            }
            guard let reader = try? AVAssetReader(asset: asset) else {
                debugStatus = "Error: AVAssetReader init failed"
                print("Failed to instantiate AVAssetReader")
                return
            }
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
            
            let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: settings)
            output.alwaysCopiesSampleData = false
            
            if reader.canAdd(output) {
                reader.add(output)
            } else {
                debugStatus = "Error: Cannot add output track"
                print("AVAssetReader cannot add output track")
                return
            }
            
            reader.timeRange = CMTimeRange(start: startTime, duration: .positiveInfinity)
            guard reader.startReading() else {
                debugStatus = "AVAssetReader start failed"
                print("AVAssetReader failed to start reading: \(reader.error?.localizedDescription ?? "unknown error")")
                return
            }
            
            self.assetReader = reader
            self.readerOutput = output
            debugStatus = "AssetReader active, starting speech task..."
            print("AVAssetReader started reading successfully at \(startTime.seconds)s")
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = false
            request.taskHint = .dictation
            
            self.recognitionRequest = request
            
            self.recognitionTask = recogniser.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                Task { @MainActor in
                    if let result = result {
                        let text = result.bestTranscription.formattedString
                        if !text.isEmpty {
                            self.debugStatus = "Text matched: \(text.prefix(15))..."
                            print("Caption recognized: \(text)")
                            self.caption = text
                            self.resetSilenceTimer()
                        }
                    }
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain != "kAFAssistantErrorDomain" || (nsError.code != 1110 && nsError.code != 203) {
                            self.debugStatus = "Speech Task Error: \(nsError.code)"
                            print("Speech recognition task error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            print("SFSpeechRecognitionTask started")
        } catch {
            debugStatus = "Asset track load cancelled/failed"
            print("Task cancelled or failed loading tracks: \(error.localizedDescription)")
        }
    }
    
    private func cleanupReaderAndRecognition() {
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        assetReader?.cancelReading()
        assetReader = nil
        readerOutput = nil
        pendingBuffer = nil
    }
    
    private func restartRecognitionTask() {
        guard isCaptionsEnabled, let player = player else { return }
        let currentTime = player.currentTime()
        debugStatus = "Restarting task at \(Int(currentTime.seconds))s"
        print("Restarting speech recognition task at time: \(currentTime.seconds)s")
        
        activeRecognitionTaskSetup?.cancel()
        activeRecognitionTaskSetup = Task {
            await startRecognitionTask(from: currentTime)
        }
    }
    
    private func pollAudioBuffer() {
        guard let player = player,
              let reader = assetReader,
              let output = readerOutput,
              reader.status == .reading else { return }
              
        let currentTime = player.currentTime()
        
        let timeDiff = abs(currentTime.seconds - lastPolledTime.seconds)
        if timeDiff > 1.0 {
            debugStatus = "Seek detected, restarting reader..."
            print("Player seek detected (diff: \(timeDiff)s). Resetting recognition task.")
            lastPolledTime = currentTime
            caption = ""
            activeRecognitionTaskSetup?.cancel()
            activeRecognitionTaskSetup = Task {
                await startRecognitionTask(from: currentTime)
            }
            return
        }
        lastPolledTime = currentTime
        
        var appendedCount = 0
        while reader.status == .reading {
            if let pending = pendingBuffer {
                let timestamp = CMSampleBufferGetPresentationTimeStamp(pending)
                if timestamp.seconds <= currentTime.seconds {
                    recognitionRequest?.appendAudioSampleBuffer(pending)
                    self.pendingBuffer = nil
                    appendedCount += 1
                } else {
                    break
                }
            }
            
            guard let sampleBuffer = output.copyNextSampleBuffer() else { break }
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            
            if timestamp.seconds <= currentTime.seconds {
                recognitionRequest?.appendAudioSampleBuffer(sampleBuffer)
                appendedCount += 1
            } else {
                self.pendingBuffer = sampleBuffer
                break
            }
        }
        
        if appendedCount > 0 {
            // Un-comment if you need verbose buffer count logs in debug overlay
            // debugStatus = "Appended \(appendedCount) buffers (time \(Int(currentTime.seconds))s)"
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.caption = ""
            }
        }
    }
    
    private func downloadVideo(from url: URL) async -> URL? {
        let fileManager = FileManager.default
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationURL = cacheDir.appendingPathComponent(UUID().uuidString + ".mp4")
        
        if url.isFileURL {
            do {
                try fileManager.copyItem(at: url, to: destinationURL)
                debugStatus = "Local file copied"
                print("Copied local video file to temp: \(destinationURL.path)")
                return destinationURL
            } catch {
                debugStatus = "Local copy failed: \(error.localizedDescription)"
                print("Failed to copy local video for captions: \(error.localizedDescription)")
                return nil
            }
        }
        
        do {
            debugStatus = "Downloading remote video..."
            print("Downloading remote video for captions from: \(url.absoluteString)")
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            try fileManager.moveItem(at: tempURL, to: destinationURL)
            debugStatus = "Download finished, cached"
            print("Successfully downloaded and cached remote video to: \(destinationURL.path)")
            return destinationURL
        } catch {
            debugStatus = "Download failed: \(error.localizedDescription)"
            print("Failed to download video for captions: \(error.localizedDescription)")
            return nil
        }
    }
}

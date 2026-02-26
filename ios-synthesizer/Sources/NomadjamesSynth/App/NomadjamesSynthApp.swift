// NomadjamesSynthApp.swift
// NomadjamesSynth
//
// This is the entry point of the iOS app.
// Every SwiftUI app has exactly one struct marked with @main.
// iOS calls the body property to build the initial window.

import SwiftUI
import AudioKit

@main
struct NomadjamesSynthApp: App {

    // Configure the audio session when the app launches
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    // MARK: - Audio session setup

    /// Configure iOS audio session for low-latency real-time audio.
    ///
    /// This tells iOS:
    ///   - We want to play audio even when the silent switch is on
    ///   - We need very low latency (important for a live performance instrument)
    ///   - We're OK mixing with other apps' audio (e.g. if Ableton is playing on Mac)
    private func configureAudioSession() {
        do {
            // AudioKit provides a convenience method for this
            // .playback = we output audio; .defaultToSpeaker = use speaker if no headphones
            try AudioKit.Settings.session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .defaultToSpeaker]
            )
            try AudioKit.Settings.session.setActive(true)

            // Request a low buffer duration for responsive performance
            // 0.005 seconds = 5ms latency (very responsive)
            // If you hear glitches, increase this to 0.010 or 0.020
            try AudioKit.Settings.session.setPreferredIOBufferDuration(0.005)

        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}

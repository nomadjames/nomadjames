// ContentView.swift
// NomadjamesSynth
//
// The main screen of the app.
// Uses a TabView to switch between three sections:
//   1. XY Pad   — touch-based pitch and filter performance surface
//   2. Sensors  — motion sensor visualization and MIDI routing
//   3. MIDI     — MIDI channel settings and connection guide
//
// All three sections share the same SynthEngine, MIDIManager, and
// MotionManager instances (created here once, passed down as dependencies).

import SwiftUI

struct ContentView: View {

    // MARK: - Shared state objects
    // These are created once here and shared with all child views.
    // @StateObject means SwiftUI owns and keeps these alive.

    @StateObject private var synth  = SynthEngine()
    @StateObject private var midi   = MIDIManager()
    @StateObject private var motion = MotionManager()

    // MARK: - Body

    var body: some View {
        TabView {

            // Tab 1: XY Performance Pad
            XYPadView(synth: synth, midi: midi)
                .tabItem {
                    Label("XY Pad", systemImage: "square.grid.3x3.middle.filled")
                }

            // Tab 2: Sensor Modulation
            SensorView(motion: motion, midi: midi)
                .tabItem {
                    Label("Sensors", systemImage: "gyroscope")
                }

            // Tab 3: MIDI Settings
            MIDISettingsView(midi: midi)
                .tabItem {
                    Label("MIDI", systemImage: "pianokeys")
                }
        }
        .preferredColorScheme(.dark)  // Always use dark mode — better for a synth app
        .accentColor(.green)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

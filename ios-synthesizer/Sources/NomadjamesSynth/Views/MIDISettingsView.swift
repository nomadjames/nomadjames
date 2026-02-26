// MIDISettingsView.swift
// NomadjamesSynth
//
// Settings panel for MIDI configuration.
// Allows the user to:
//   - Choose which MIDI channel to send notes and CC on (1–16)
//   - Toggle MIDI output on/off (e.g. when just want audio locally)
//   - See the status of the virtual MIDI port
//   - View a quick-reference for connecting to Ableton Live

import SwiftUI

struct MIDISettingsView: View {

    @ObservedObject var midi: MIDIManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Header
                VStack(spacing: 4) {
                    Text("MIDI Settings")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(midi.statusMessage)
                        .font(.caption)
                        .foregroundColor(midi.midiEnabled ? .green : .gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)

                // Status indicator
                statusCard

                // MIDI enable toggle
                settingsCard {
                    Toggle(isOn: $midi.midiEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Send MIDI Output")
                                .foregroundColor(.white)
                            Text("When OFF, the app plays audio locally but sends no MIDI to Ableton.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.green)
                }

                // Channel picker
                settingsCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MIDI Channel")
                            .foregroundColor(.white)
                        Text("Ableton Live defaults to receiving on all channels. Set this to match any specific instrument in your Live set.")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Picker("MIDI Channel", selection: $midi.midiChannel) {
                            ForEach(1...16, id: \.self) { ch in
                                Text("Channel \(ch)").tag(ch)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .tint(.green)
                    }
                }

                // Connection guide
                connectionGuide

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
    }

    // MARK: - Status card

    private var statusCard: some View {
        HStack(spacing: 16) {
            // Status dot
            Circle()
                .fill(midi.midiEnabled ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
                .shadow(color: midi.midiEnabled ? .green : .clear, radius: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text("Virtual MIDI Port")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("\"NomadjamesSynth\" — appears in Ableton's MIDI prefs when connected via USB")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
        .cornerRadius(12)
    }

    // MARK: - Connection guide

    private var connectionGuide: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How to Connect to Ableton Live")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 12)

            ForEach(connectionSteps, id: \.step) { item in
                HStack(alignment: .top, spacing: 12) {
                    // Step number circle
                    Text("\(item.step)")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .frame(width: 22, height: 22)
                        .background(Color.green)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text(item.detail)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)

                if item.step < connectionSteps.count {
                    Divider()
                        .background(Color.white.opacity(0.08))
                }
            }
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
        .cornerRadius(12)
    }

    // MARK: - Step data

    private struct ConnectionStep {
        let step: Int
        let title: String
        let detail: String
    }

    private let connectionSteps: [ConnectionStep] = [
        ConnectionStep(
            step: 1,
            title: "Connect iPhone to Mac via USB",
            detail: "Use the Lightning or USB-C cable that came with your iPhone."
        ),
        ConnectionStep(
            step: 2,
            title: "Open Ableton Live on your Mac",
            detail: "Any version of Live (Intro, Standard, Suite) works."
        ),
        ConnectionStep(
            step: 3,
            title: "Open Ableton Preferences → MIDI",
            detail: "Press Cmd + , (comma) in Ableton, then click the MIDI tab."
        ),
        ConnectionStep(
            step: 4,
            title: "Find \"NomadjamesSynth\" in MIDI Ports",
            detail: "Enable the Track and Remote toggles for this port so Ableton receives MIDI from it."
        ),
        ConnectionStep(
            step: 5,
            title: "Arm a MIDI track in Ableton",
            detail: "Add a MIDI track, set its input to NomadjamesSynth, press the arm (record) button, then play the XY pad."
        )
    ]

    // MARK: - Helper: settings card container

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(Color(red: 0.1, green: 0.1, blue: 0.15))
            .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    MIDISettingsView(midi: MIDIManager())
        .preferredColorScheme(.dark)
}

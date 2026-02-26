// XYPadView.swift
// NomadjamesSynth
//
// The XY Pad is the main performance surface of the app.
// It's a dark square you touch with your finger:
//   - Moving LEFT/RIGHT changes pitch (which note plays)
//   - Moving UP/DOWN changes filter cutoff (how bright/dark the sound is)
//
// When you lift your finger, the note stops.
// The glowing dot follows your touch position.

import SwiftUI

struct XYPadView: View {

    // MARK: - External objects (injected by ContentView)
    @ObservedObject var synth: SynthEngine
    @ObservedObject var midi: MIDIManager

    // MARK: - Local state

    /// Current touch position in the pad (0.0 to 1.0 for both axes)
    @State private var touchPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)

    /// Whether a finger is currently on the pad
    @State private var isTouching: Bool = false

    /// Which musical scale to use for pitch mapping
    @State private var selectedScale: ScaleOption = .minorPentatonic

    // MARK: - Scale options

    enum ScaleOption: String, CaseIterable, Identifiable {
        case minorPentatonic = "Minor Penta"
        case majorScale      = "Major"
        case wholeTone       = "Whole Tone"
        case chromatic       = "Chromatic"

        var id: String { rawValue }

        var notes: [Int] {
            switch self {
            case .minorPentatonic: return MusicTheory.minorPentatonic
            case .majorScale:      return MusicTheory.majorScale
            case .wholeTone:       return MusicTheory.wholeTone
            case .chromatic:       return MusicTheory.chromatic
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {

            // Title + scale picker
            HStack {
                Text("XY Pad")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Picker("Scale", selection: $selectedScale) {
                    ForEach(ScaleOption.allCases) { scale in
                        Text(scale.rawValue).tag(scale)
                    }
                }
                .pickerStyle(.menu)
                .tint(.green)
            }
            .padding(.horizontal)

            // The pad surface itself
            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isTouching ? Color.green.opacity(0.8) : Color.gray.opacity(0.3), lineWidth: 1.5)
                        )

                    // Grid lines (subtle visual guide)
                    gridLines(in: geometry.size)

                    // Axis labels
                    axisLabels(in: geometry.size)

                    // The glowing touch dot (only shown while touching)
                    if isTouching {
                        touchDot(in: geometry.size)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleTouch(location: value.location, size: geometry.size)
                        }
                        .onEnded { _ in
                            handleTouchEnd()
                        }
                )
            }
            .aspectRatio(1.0, contentMode: .fit)  // Keep the pad square
            .padding(.horizontal)

            // Live readout of current values
            valueReadout
                .padding(.horizontal)

            // Waveform selector
            waveformPicker
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
    }

    // MARK: - Subviews

    /// Faint crosshair grid lines on the pad surface
    @ViewBuilder
    private func gridLines(in size: CGSize) -> some View {
        // Vertical center line
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(width: 1, height: size.height)
            .position(x: size.width / 2, y: size.height / 2)

        // Horizontal center line
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(width: size.width, height: 1)
            .position(x: size.width / 2, y: size.height / 2)
    }

    /// X and Y axis labels at the edges of the pad
    @ViewBuilder
    private func axisLabels(in size: CGSize) -> some View {
        // Left edge: "Dark" (low filter)
        Text("Dark")
            .font(.caption2)
            .foregroundColor(.gray)
            .position(x: 28, y: size.height - 12)

        // Right edge: "Bright" (high filter) — wait, Y is up/down
        // Bottom: low pitch, Top: high pitch (X is pitch)
        Text("Low")
            .font(.caption2)
            .foregroundColor(.gray)
            .position(x: 20, y: size.height - 12)

        Text("High")
            .font(.caption2)
            .foregroundColor(.gray)
            .position(x: size.width - 20, y: size.height - 12)

        Text("Bright")
            .font(.caption2)
            .foregroundColor(.gray)
            .position(x: 28, y: 12)
    }

    /// The glowing dot that follows the user's finger
    @ViewBuilder
    private func touchDot(in size: CGSize) -> some View {
        let dotX = touchPosition.x * size.width
        let dotY = touchPosition.y * size.height

        ZStack {
            // Outer glow
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 60, height: 60)

            // Middle ring
            Circle()
                .fill(Color.green.opacity(0.4))
                .frame(width: 30, height: 30)

            // Inner bright dot
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
        }
        .position(x: dotX, y: dotY)
        .animation(.easeOut(duration: 0.05), value: touchPosition)
    }

    /// Shows the current pitch note and filter cutoff value
    private var valueReadout: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("PITCH")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(pitchLabel)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("FILTER")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("\(Int(synth.filterCutoff)) Hz")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
            }
        }
    }

    /// Buttons to switch between oscillator waveforms
    private var waveformPicker: some View {
        HStack(spacing: 8) {
            ForEach(Waveform.allCases) { wave in
                Button(wave.rawValue) {
                    synth.waveform = wave
                }
                .buttonStyle(.bordered)
                .tint(synth.waveform == wave ? .green : .gray)
                .font(.caption)
            }
        }
    }

    // MARK: - Touch handling

    /// Called every time the finger moves on the pad.
    private func handleTouch(location: CGPoint, size: CGSize) {
        // Clamp the touch position to 0.0...1.0 range
        let x = max(0, min(1, location.x / size.width))
        let y = max(0, min(1, 1 - (location.y / size.height))) // invert Y: bottom = 0, top = 1

        touchPosition = CGPoint(x: x, y: CGFloat(1 - y))  // for dot display (screen coords)

        // First touch: start the note
        if !isTouching {
            isTouching = true
        }

        // Update pitch (X axis) and filter (Y axis)
        synth.setPitchFromNormalized(Float(x), scale: selectedScale.notes)
        synth.setCutoffFromNormalized(Float(y))

        // If the synth isn't playing yet, start it
        if !synth.isPlaying {
            // Find the nearest MIDI note for the current X position
            let noteIndex = Int((Float(x) * Float(selectedScale.notes.count - 1)).rounded())
            let note = selectedScale.notes[max(0, min(selectedScale.notes.count - 1, noteIndex))]
            synth.noteOn(midiNote: note)
            midi.sendNoteOn(note: note)
        }

        // Send filter cutoff as MIDI CC to Ableton
        midi.sendCC(cc: MIDIControllers.filterCutoff, value: Int(Float(y) * 127))
    }

    /// Called when the finger lifts off the pad.
    private func handleTouchEnd() {
        isTouching = false
        synth.noteOff()

        // Send Note Off for the last-played note
        let noteIndex = Int((Float(touchPosition.x) * Float(selectedScale.notes.count - 1)).rounded())
        let note = selectedScale.notes[max(0, min(selectedScale.notes.count - 1, noteIndex))]
        midi.sendNoteOff(note: note)
    }

    // MARK: - Helpers

    /// Returns the note name for the current X position (e.g. "C4", "Eb4")
    private var pitchLabel: String {
        let notes = selectedScale.notes
        let index = Int((Float(touchPosition.x) * Float(notes.count - 1)).rounded())
        let clampedIndex = max(0, min(notes.count - 1, index))
        return midiNoteToName(notes[clampedIndex])
    }

    /// Converts a MIDI note number to a human-readable name like "C4" or "F#3"
    private func midiNoteToName(_ note: Int) -> String {
        let noteNames = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        let octave = (note / 12) - 1
        let noteName = noteNames[note % 12]
        return "\(noteName)\(octave)"
    }
}

// MARK: - Preview

#Preview {
    XYPadView(
        synth: SynthEngine(),
        midi: MIDIManager()
    )
    .preferredColorScheme(.dark)
}

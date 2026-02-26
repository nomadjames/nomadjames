// SynthEngine.swift
// NomadjamesSynth
//
// The audio brain of the app. Manages the synthesizer's sound engine:
//   - An oscillator that generates the raw sound wave
//   - A Moog Ladder filter that shapes the tone (the classic "warm" filter)
//   - Reverb and Delay effects for space and depth
//
// This class is an ObservableObject, which means SwiftUI views can
// watch its properties and automatically update when they change.

import AudioKit
import Foundation

/// Waveform choices for the oscillator.
/// Each waveform has a different "character" — try them all!
enum Waveform: String, CaseIterable, Identifiable {
    case sine     = "Sine"      // Smooth, pure tone
    case sawtooth = "Sawtooth"  // Bright, buzzy (classic analog synth sound)
    case square   = "Square"    // Hollow, reedy (great for bass lines)
    case triangle = "Triangle"  // Softer than square, warmer than sine

    var id: String { rawValue }
}

/// SynthEngine manages all audio processing for the app.
/// Mark it @MainActor so UI updates happen safely on the main thread.
@MainActor
class SynthEngine: ObservableObject {

    // MARK: - AudioKit nodes

    private let engine = AudioEngine()
    private var oscillator: PlaygroundOscillator
    private var filter: MoogLadder
    private var reverb: Reverb
    private var delay: Delay
    private var mixer: Mixer

    // MARK: - Published properties
    // When these change, any SwiftUI view observing this object will redraw.

    /// Current oscillator waveform
    @Published var waveform: Waveform = .sawtooth {
        didSet { applyWaveform() }
    }

    /// Oscillator volume (0.0 = silent, 1.0 = full)
    @Published var volume: Float = 0.7 {
        didSet { oscillator.amplitude = AUValue(volume) }
    }

    /// Filter cutoff frequency in Hz (20 = very dark, 10000 = very bright)
    @Published var filterCutoff: Float = 2000 {
        didSet { filter.cutoffFrequency = AUValue(filterCutoff) }
    }

    /// Filter resonance (0.0 = flat, 1.0 = self-oscillating / intense)
    @Published var filterResonance: Float = 0.3 {
        didSet { filter.resonance = AUValue(filterResonance) }
    }

    /// Reverb mix (0.0 = dry, 1.0 = fully wet)
    @Published var reverbMix: Float = 0.3 {
        didSet { reverb.dryWetMix = AUValue(reverbMix) }
    }

    /// Delay time in seconds (0.1 = tight echo, 0.75 = slapback, 1.0 = long echo)
    @Published var delayTime: Float = 0.25 {
        didSet { delay.time = AUValue(delayTime) }
    }

    /// Delay feedback (0.0 = single echo, 0.9 = many repeating echoes)
    @Published var delayFeedback: Float = 0.3 {
        didSet { delay.feedback = AUValue(delayFeedback) }
    }

    /// Whether any note is currently playing
    @Published var isPlaying: Bool = false

    // MARK: - Initializer

    init() {
        // 1. Create the oscillator with default settings
        oscillator = PlaygroundOscillator(waveform: Table(.sawtooth))
        oscillator.frequency = 440  // A4 (concert A)
        oscillator.amplitude = 0.7

        // 2. Create the filter and connect oscillator → filter
        filter = MoogLadder(oscillator)
        filter.cutoffFrequency = 2000
        filter.resonance = 0.3

        // 3. Add reverb: filter → reverb
        reverb = Reverb(filter)
        reverb.dryWetMix = 0.3

        // 4. Add delay: reverb → delay
        delay = Delay(reverb)
        delay.time = 0.25
        delay.feedback = 0.3
        delay.dryWetMix = 0.4

        // 5. Mix everything and connect to the audio engine output
        mixer = Mixer(delay)
        engine.output = mixer

        // 6. Start the audio engine
        do {
            try engine.start()
        } catch {
            print("AudioKit failed to start: \(error)")
        }
    }

    // MARK: - Playback control

    /// Start playing a note at a given MIDI note number (0–127).
    /// Middle C = 60, A4 = 69.
    func noteOn(midiNote: Int, velocity: Float = 0.8) {
        let frequency = midiNoteToFrequency(midiNote)
        oscillator.frequency = AUValue(frequency)
        oscillator.amplitude = AUValue(velocity * volume)
        oscillator.start()
        isPlaying = true
    }

    /// Stop the current note.
    func noteOff() {
        oscillator.stop()
        isPlaying = false
    }

    /// Set pitch directly from a normalized 0–1 value.
    /// Maps the range to a musical scale within a 2-octave window.
    /// Used by the XY pad's X-axis.
    func setPitchFromNormalized(_ value: Float, scale: [Int] = MusicTheory.minorPentatonic) {
        let noteIndex = Int((value * Float(scale.count - 1)).rounded())
        let clampedIndex = max(0, min(scale.count - 1, noteIndex))
        let midiNote = scale[clampedIndex]
        let frequency = midiNoteToFrequency(midiNote)
        oscillator.frequency = AUValue(frequency)
    }

    /// Set filter cutoff from a normalized 0–1 value.
    /// Maps to a useful frequency range (100 Hz to 8000 Hz).
    /// Used by the XY pad's Y-axis.
    func setCutoffFromNormalized(_ value: Float) {
        // Exponential mapping feels more natural for frequency
        let minFreq: Float = 100
        let maxFreq: Float = 8000
        let cutoff = minFreq * pow(maxFreq / minFreq, value)
        filterCutoff = cutoff
    }

    // MARK: - Private helpers

    /// Convert a MIDI note number to a frequency in Hz.
    /// Formula: 440 * 2^((note - 69) / 12)
    private func midiNoteToFrequency(_ note: Int) -> Float {
        return 440.0 * pow(2.0, Float(note - 69) / 12.0)
    }

    /// Apply the current waveform setting to the oscillator.
    private func applyWaveform() {
        switch waveform {
        case .sine:
            oscillator.setWaveform(Table(.sine))
        case .sawtooth:
            oscillator.setWaveform(Table(.sawtooth))
        case .square:
            oscillator.setWaveform(Table(.square))
        case .triangle:
            oscillator.setWaveform(Table(.triangle))
        }
    }
}

// MARK: - Music Theory helpers

/// A small collection of musical scale definitions.
/// Each array contains MIDI note numbers for one octave starting at C4 (60).
enum MusicTheory {
    /// C minor pentatonic: C Eb F G Bb (+ octave up)
    static let minorPentatonic: [Int] = [60, 63, 65, 67, 70, 72, 75, 77, 79, 82]

    /// C major scale: C D E F G A B (+ octave up)
    static let majorScale: [Int] = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76]

    /// C chromatic (all 12 notes)
    static let chromatic: [Int] = Array(60...84)

    /// Whole tone scale: C D E F# G# A# (dreamy, ambiguous)
    static let wholeTone: [Int] = [60, 62, 64, 66, 68, 70, 72, 74, 76]
}

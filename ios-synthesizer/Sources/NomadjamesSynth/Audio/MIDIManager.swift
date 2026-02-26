// MIDIManager.swift
// NomadjamesSynth
//
// Handles all MIDI communication between the app and the outside world.
//
// What is MIDI?
//   MIDI (Musical Instrument Digital Interface) is a protocol that lets
//   electronic instruments and software talk to each other. Instead of
//   sending audio, MIDI sends *instructions* like "play note 60 at velocity 80"
//   or "set knob #1 to value 64".
//
// What this file does:
//   Creates a "virtual MIDI source" — an invisible MIDI port that Ableton Live
//   (and other DAWs) can see and receive MIDI from, without any extra hardware.
//   When you connect your iPhone to your Mac via USB, this port appears in
//   Ableton Live's MIDI preferences automatically.

import CoreMIDI
import Foundation

/// Manages a virtual MIDI output port.
/// Other apps (like Ableton Live) can subscribe to this port.
@MainActor
class MIDIManager: ObservableObject {

    // MARK: - Published state

    /// The MIDI channel to send messages on (1–16).
    /// Ableton Live listens on specific channels — match this to your Live setup.
    @Published var midiChannel: Int = 1

    /// Whether MIDI output is enabled. When false, no MIDI is sent.
    @Published var midiEnabled: Bool = true

    /// Human-readable status for the UI (e.g. "Virtual port ready")
    @Published var statusMessage: String = "Initializing..."

    // MARK: - CoreMIDI internals
    // These are low-level CoreMIDI objects. You don't need to modify them.

    private var midiClient: MIDIClientRef = 0
    private var outputPort: MIDIPortRef = 0
    private var virtualSource: MIDIEndpointRef = 0

    // MARK: - Init

    init() {
        setupMIDI()
    }

    // MARK: - Setup

    /// Creates the CoreMIDI client, output port, and virtual MIDI source.
    private func setupMIDI() {
        // Step 1: Create a MIDI client (your app's connection to the MIDI system)
        let clientName = "NomadjamesSynth" as CFString
        let status = MIDIClientCreate(clientName, nil, nil, &midiClient)

        guard status == noErr else {
            statusMessage = "Failed to create MIDI client (error \(status))"
            return
        }

        // Step 2: Create an output port (used to send MIDI messages)
        let portName = "Output" as CFString
        let portStatus = MIDIOutputPortCreate(midiClient, portName, &outputPort)

        guard portStatus == noErr else {
            statusMessage = "Failed to create MIDI port (error \(portStatus))"
            return
        }

        // Step 3: Create a virtual MIDI source.
        // This is the "instrument" that Ableton Live will see.
        // Name it something descriptive — this is what appears in Ableton.
        let sourceName = "NomadjamesSynth" as CFString
        let sourceStatus = MIDISourceCreate(midiClient, sourceName, &virtualSource)

        guard sourceStatus == noErr else {
            statusMessage = "Failed to create virtual MIDI source (error \(sourceStatus))"
            return
        }

        statusMessage = "Virtual port ready — connect USB and open Ableton"
    }

    // MARK: - Sending MIDI

    /// Send a Note On message: start playing a note.
    ///
    /// - Parameters:
    ///   - note: MIDI note number (0–127). Middle C = 60.
    ///   - velocity: How hard the note is "struck" (0–127). 0 = silent, 127 = loudest.
    func sendNoteOn(note: Int, velocity: Int = 100) {
        guard midiEnabled else { return }

        // MIDI channel is 1-indexed in the UI but 0-indexed in the protocol
        let channelByte = UInt8(midiChannel - 1)

        // Note On status byte: 0x90 | channel
        let statusByte: UInt8 = 0x90 | channelByte
        let noteByte = UInt8(clamping: note)
        let velocityByte = UInt8(clamping: velocity)

        sendMIDIBytes([statusByte, noteByte, velocityByte])
    }

    /// Send a Note Off message: stop playing a note.
    ///
    /// - Parameters:
    ///   - note: The same note number that was started with sendNoteOn.
    func sendNoteOff(note: Int) {
        guard midiEnabled else { return }

        let channelByte = UInt8(midiChannel - 1)
        // Note Off status byte: 0x80 | channel
        let statusByte: UInt8 = 0x80 | channelByte
        let noteByte = UInt8(clamping: note)

        sendMIDIBytes([statusByte, noteByte, 0])
    }

    /// Send a Control Change (CC) message.
    ///
    /// CC messages control knobs, faders, and parameters in Ableton Live.
    /// For example: CC#1 = Modulation Wheel, CC#74 = Filter Cutoff (common mapping).
    ///
    /// - Parameters:
    ///   - cc: Controller number (0–127). See MIDIControllers enum below.
    ///   - value: Controller value (0–127).
    func sendCC(cc: Int, value: Int) {
        guard midiEnabled else { return }

        let channelByte = UInt8(midiChannel - 1)
        // Control Change status byte: 0xB0 | channel
        let statusByte: UInt8 = 0xB0 | channelByte
        let ccByte = UInt8(clamping: cc)
        let valueByte = UInt8(clamping: value)

        sendMIDIBytes([statusByte, ccByte, valueByte])
    }

    /// Send a Pitch Bend message.
    ///
    /// Pitch bend uses 14 bits (0–16383) for fine resolution.
    /// Center (no bend) = 8192.
    ///
    /// - Parameter value: 0–16383. 8192 = no bend, 0 = full down, 16383 = full up.
    func sendPitchBend(value: Int) {
        guard midiEnabled else { return }

        let channelByte = UInt8(midiChannel - 1)
        // Pitch Bend status byte: 0xE0 | channel
        let statusByte: UInt8 = 0xE0 | channelByte

        // Split 14-bit value into two 7-bit bytes (LSB first, then MSB)
        let lsb = UInt8(value & 0x7F)
        let msb = UInt8((value >> 7) & 0x7F)

        sendMIDIBytes([statusByte, lsb, msb])
    }

    // MARK: - Convenience: sensor-mapped CC senders

    /// Send sensor data as MIDI CC.
    /// Converts a Float in range -1.0...1.0 (raw sensor) to 0...127 (MIDI CC value).
    ///
    /// - Parameters:
    ///   - sensorValue: Raw sensor value, typically -1.0 to 1.0
    ///   - cc: The MIDI CC number to send it on
    func sendSensorAsCC(sensorValue: Float, cc: Int) {
        // Map -1.0...1.0 → 0...127
        let normalized = (sensorValue + 1.0) / 2.0          // 0.0...1.0
        let midiValue = Int((normalized * 127).rounded())   // 0...127
        let clamped = max(0, min(127, midiValue))
        sendCC(cc: cc, value: clamped)
    }

    // MARK: - Low-level send

    /// Internal method that packages bytes into a MIDI packet and sends it
    /// via the virtual source (so Ableton and other apps receive it).
    private func sendMIDIBytes(_ bytes: [UInt8]) {
        // MIDIPacketList is how CoreMIDI packages one or more MIDI messages
        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)

        packet = MIDIPacketListAdd(
            &packetList,
            MemoryLayout<MIDIPacketList>.size,
            packet,
            0,  // timestamp 0 = send immediately
            bytes.count,
            bytes
        )

        // Receive on the virtual source — connected clients (Ableton) will get this
        MIDIReceived(virtualSource, &packetList)
    }

    deinit {
        // Clean up CoreMIDI resources
        if virtualSource != 0 { MIDIEndpointDispose(virtualSource) }
        if outputPort != 0    { MIDIPortDispose(outputPort) }
        if midiClient != 0    { MIDIClientDispose(midiClient) }
    }
}

// MARK: - Common MIDI CC numbers

/// Commonly used MIDI Controller Change (CC) numbers.
/// Use these when mapping sensor data to Ableton parameters.
enum MIDIControllers {
    static let modulationWheel  = 1    // Classic mod wheel — great for vibrato
    static let breathController = 2    // Breath sensor (rare but expressive)
    static let volume           = 7    // Channel volume
    static let pan              = 10   // Left/right stereo position
    static let filterCutoff     = 74   // Filter frequency (many synths use this)
    static let filterResonance  = 71   // Filter resonance / Q
    static let reverbSend       = 91   // Reverb mix
    static let delaySend        = 92   // Delay/echo mix
    static let chorusSend       = 93   // Chorus mix
    static let pitchBendRange   = 52   // Custom: not a standard CC, use pitch bend msg instead
    static let expressionPedal  = 11   // Expression / dynamics
    static let sustainPedal     = 64   // Hold pedal (127 = hold, 0 = release)
}

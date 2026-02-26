# iOS Synthesizer Project

A touch- and sensor-controlled sound engine for iPhone/iPad that interfaces with **Ableton Live** and **modular synthesizers** via MIDI.

Built with **Swift + SwiftUI + AudioKit 5**.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                     iOS App                         │
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  XY Pad UI  │  │  Sensor View │  │MIDI Config│  │
│  └──────┬──────┘  └──────┬───────┘  └─────┬─────┘  │
│         │                │                │         │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              ContentView (TabView)             │  │
│  └──────────────────────┬─────────────────────── ┘  │
│                         │                            │
│         ┌───────────────┼────────────────┐           │
│         ▼               ▼                ▼           │
│  ┌─────────────┐  ┌───────────────┐  ┌──────────┐  │
│  │ SynthEngine │  │ MotionManager │  │MIDIManager│  │
│  │ (AudioKit)  │  │  (CoreMotion) │  │(CoreMIDI) │  │
│  └──────┬──────┘  └───────┬───────┘  └────┬─────┘  │
└─────────┼─────────────────┼───────────────┼─────────┘
          │                 │               │
          ▼                 ▼               ▼
    Audio Output      Sensor Data     Virtual MIDI Port
    (headphones/       (accel +        (seen by Ableton
     speaker)          gyro axes)       automatically)
```

---

## Features

| Feature | Description |
|---|---|
| XY Touch Pad | X-axis controls pitch within a selected scale; Y-axis controls filter cutoff |
| Sensor Modulation | Accelerometer and gyroscope map to MIDI CC values (filter, reverb, pitch bend) |
| Virtual MIDI Port | Appears in Ableton Live's MIDI preferences — no extra hardware needed |
| Waveform Selection | Sine, Sawtooth, Square, Triangle oscillator modes |
| Filter | Moog Ladder filter with cutoff and resonance |
| Effects | Reverb and Delay with mix controls |
| MIDI Settings | Choose MIDI channel (1–16), toggle audio-only vs MIDI-out mode |

---

## Requirements

| Requirement | Version |
|---|---|
| macOS (for development) | 13.0 Ventura or later |
| Xcode | 15.0 or later |
| iOS target | 16.0 or later |
| Swift | 5.9 or later |
| AudioKit | 5.6+ (fetched via Swift Package Manager) |

> **Note:** iOS/Swift apps require a Mac with Xcode to compile. The source files in this repo are ready to open — see setup instructions below.

---

## Setup Instructions

### 1. Open the project in Xcode

1. Clone this repository on your Mac:
   ```bash
   git clone https://github.com/nomadjames/nomadjames.git
   cd nomadjames/ios-synthesizer
   ```

2. Open the `Package.swift` file in Xcode:
   ```bash
   open Package.swift
   ```
   Xcode will resolve the AudioKit package automatically (requires internet).

3. Select your iPhone or an iPhone Simulator as the build target.

4. Press **Cmd + R** to build and run.

### 2. Connect to Ableton Live via USB MIDI

1. Connect your iPhone/iPad to your Mac with a USB cable.
2. On Mac, open **Audio MIDI Setup** (search in Spotlight).
3. Go to **Window → MIDI Studio** — you should see your iPhone listed.
4. Enable **MIDI** on the iPhone device.
5. Open **Ableton Live → Preferences → MIDI**.
6. Under *MIDI Ports*, find **"NomadjamesSynth"** and enable **Track** and **Remote** input.
7. Play the XY pad — MIDI notes will appear in Ableton's MIDI monitor.

### 3. Connect via WiFi MIDI (alternative to USB)

1. On Mac, open **Audio MIDI Setup → Window → MIDI Studio**.
2. Double-click **Network** — enable "Session 1" and add your iPhone.
3. Ableton will see the wireless MIDI port the same way as USB.

### 4. Connect to a Modular Synthesizer

Modular synths speak **CV (Control Voltage)**, not MIDI directly. You have two options:

**Option A — MIDI-to-CV Converter (recommended)**
- Hardware examples: Korg SQ-1, Expert Sleepers FH-2, Mutable Instruments Yarns
- Connect iPhone → Mac (USB MIDI) → MIDI interface → MIDI-CV converter → modular

**Option B — Expert Sleepers ES-8 / ES-9**
- DC-coupled audio interface that sends CV directly from a Mac/iOS app
- Advanced setup; see [Expert Sleepers documentation](https://www.expert-sleepers.co.uk)

---

## Project File Structure

```
ios-synthesizer/
├── README.md               ← You are here
├── Package.swift           ← Swift Package Manager (declares AudioKit dependency)
├── .gitignore
└── Sources/
    └── NomadjamesSynth/
        ├── App/
        │   ├── NomadjamesSynthApp.swift   ← @main entry point
        │   └── ContentView.swift          ← TabView navigation shell
        ├── Audio/
        │   ├── SynthEngine.swift          ← Oscillator, filter, effects (AudioKit)
        │   └── MIDIManager.swift          ← Virtual MIDI port, note/CC output
        ├── Sensors/
        │   └── MotionManager.swift        ← Accelerometer + gyroscope
        └── Views/
            ├── XYPadView.swift            ← Touch X/Y pad surface
            ├── SensorView.swift           ← Live sensor data visualization
            └── MIDISettingsView.swift     ← MIDI channel + mode settings
```

---

## Learning Resources

- [AudioKit Documentation](https://audiokit.io/documentation/)
- [AudioKit Cookbook (example apps)](https://github.com/AudioKit/Cookbook)
- [SwiftUI Tutorials (Apple)](https://developer.apple.com/tutorials/swiftui)
- [CoreMIDI Overview](https://developer.apple.com/documentation/coremidi)
- [CoreMotion Overview](https://developer.apple.com/documentation/coremotion)
- [Ableton Live MIDI Setup Guide](https://www.ableton.com/en/packs/max-msp/)

---

## Roadmap

- [ ] Phase 1 (current): Touch XY pad + MIDI output + sensor modulation
- [ ] Phase 2: Polyphony (multiple simultaneous notes), arpeggiator
- [ ] Phase 3: Preset save/load system
- [ ] Phase 4: Ableton Push-style pad grid layout
- [ ] Phase 5: AUv3 Audio Unit plugin (runs inside other iOS DAWs)

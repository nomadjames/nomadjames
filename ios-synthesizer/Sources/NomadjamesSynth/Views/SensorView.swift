// SensorView.swift
// NomadjamesSynth
//
// Shows a live visualization of the iPhone's motion sensor data.
// Each axis of the accelerometer and gyroscope is shown as a bar.
// Toggling an axis "arms" it as a MIDI modulation source —
// when armed, that sensor value is continuously sent as a MIDI CC
// to Ableton Live.

import SwiftUI

struct SensorView: View {

    @ObservedObject var motion: MotionManager
    @ObservedObject var midi: MIDIManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Header
                sectionHeader(
                    title: "Motion Sensors",
                    subtitle: motion.statusMessage
                )

                // Start/stop button
                Button(action: { motion.toggle() }) {
                    Label(
                        motion.isActive ? "Pause Sensors" : "Start Sensors",
                        systemImage: motion.isActive ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(motion.isActive ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                    .foregroundColor(motion.isActive ? .orange : .green)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Accelerometer section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Accelerometer")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Detects tilt and gravity. Values range from -1 (full tilt one way) to +1 (full tilt other way).")
                            .font(.caption)
                            .foregroundColor(.gray)

                        SensorAxisRow(
                            label: "X  (tilt left/right)",
                            value: motion.accelerometer.x,
                            isArmed: $motion.accelXArmed,
                            midiCC: MIDIControllers.filterCutoff,
                            color: .cyan
                        )

                        SensorAxisRow(
                            label: "Y  (tilt forward/back)",
                            value: motion.accelerometer.y,
                            isArmed: $motion.accelYArmed,
                            midiCC: MIDIControllers.reverbSend,
                            color: .purple
                        )

                        SensorAxisRow(
                            label: "Z  (face-up vs. face-down)",
                            value: motion.accelerometer.z,
                            isArmed: $motion.accelZArmed,
                            midiCC: MIDIControllers.volume,
                            color: .pink
                        )
                    }
                }
                .groupBoxStyle(DarkGroupBoxStyle())
                .padding(.horizontal)

                // Gyroscope section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gyroscope")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Detects rotation speed. Flick or rotate the phone to generate expressive movements.")
                            .font(.caption)
                            .foregroundColor(.gray)

                        SensorAxisRow(
                            label: "Z  (spinning, face toward you)",
                            value: motion.gyroscope.z,
                            isArmed: $motion.gyroZArmed,
                            midiCC: MIDIControllers.delaySend,
                            color: .yellow
                        )

                        SensorAxisRow(
                            label: "X  (pitch: nodding up/down)",
                            value: motion.gyroscope.x,
                            isArmed: .constant(false),  // not armed by default
                            midiCC: MIDIControllers.modulationWheel,
                            color: .orange
                        )
                    }
                }
                .groupBoxStyle(DarkGroupBoxStyle())
                .padding(.horizontal)

                // MIDI CC routing legend
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default MIDI CC Routing")
                            .font(.headline)
                            .foregroundColor(.white)

                        CCRoutingRow(sensor: "Accel X", cc: MIDIControllers.filterCutoff, name: "Filter Cutoff (CC 74)")
                        CCRoutingRow(sensor: "Accel Y", cc: MIDIControllers.reverbSend,   name: "Reverb Send (CC 91)")
                        CCRoutingRow(sensor: "Gyro Z",  cc: MIDIControllers.delaySend,    name: "Delay Send (CC 92)")
                    }
                }
                .groupBoxStyle(DarkGroupBoxStyle())
                .padding(.horizontal)

                Spacer(minLength: 32)
            }
            .padding(.top)
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
        // Send MIDI CC whenever armed sensor values change
        .onChange(of: motion.accelerometer.x) { _, val in
            if motion.accelXArmed {
                midi.sendSensorAsCC(sensorValue: Float(val), cc: MIDIControllers.filterCutoff)
            }
        }
        .onChange(of: motion.accelerometer.y) { _, val in
            if motion.accelYArmed {
                midi.sendSensorAsCC(sensorValue: Float(val), cc: MIDIControllers.reverbSend)
            }
        }
        .onChange(of: motion.gyroscope.z) { _, val in
            if motion.gyroZArmed {
                midi.sendSensorAsCC(sensorValue: Float(val), cc: MIDIControllers.delaySend)
            }
        }
    }

    // MARK: - Section header helper

    @ViewBuilder
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SensorAxisRow

/// One row showing a single axis value as a bar graph + arm toggle.
struct SensorAxisRow: View {
    let label: String
    let value: Double
    @Binding var isArmed: Bool
    let midiCC: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Arm/disarm toggle
                Toggle("", isOn: $isArmed)
                    .labelsHidden()
                    .tint(color)

                Text(label)
                    .font(.caption)
                    .foregroundColor(isArmed ? .white : .gray)

                Spacer()

                // Numeric value
                Text(String(format: "%.2f", value))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(color)

                // MIDI CC number
                if isArmed {
                    Text("CC \(midiCC)")
                        .font(.caption2)
                        .foregroundColor(color.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            // Bar visualization
            // Center line at 0; bar extends left or right based on value
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)

                    // Center marker
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 8)
                        .position(x: geo.size.width / 2, y: 4)

                    // Value bar
                    let barWidth = abs(value) * Double(geo.size.width) / 2
                    let barOriginX = value >= 0
                        ? geo.size.width / 2
                        : geo.size.width / 2 - barWidth

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isArmed ? color : color.opacity(0.3))
                        .frame(width: max(2, barWidth), height: 8)
                        .offset(x: barOriginX)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - CCRoutingRow

struct CCRoutingRow: View {
    let sensor: String
    let cc: Int
    let name: String

    var body: some View {
        HStack {
            Text(sensor)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.gray)

            Text(name)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Custom GroupBox style

struct DarkGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    SensorView(
        motion: MotionManager(),
        midi: MIDIManager()
    )
    .preferredColorScheme(.dark)
}

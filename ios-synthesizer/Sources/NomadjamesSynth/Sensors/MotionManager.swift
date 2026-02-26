// MotionManager.swift
// NomadjamesSynth
//
// Reads motion data from the iPhone's built-in sensors:
//   - Accelerometer: detects tilt and movement (gravity + motion)
//   - Gyroscope: detects rotation speed around each axis
//
// How these map to music:
//   Accelerometer X (tilt left/right)  → Pitch bend or filter sweep
//   Accelerometer Y (tilt forward/back) → Reverb mix
//   Accelerometer Z (flat vs. face-up) → Oscillator volume
//   Gyroscope Z (spinning face)         → Delay feedback
//
// All values are published so SwiftUI views can display them live
// and the MIDIManager can send them as CC messages.

import CoreMotion
import Foundation

/// Holds the X, Y, Z values from a sensor at one moment in time.
struct SensorReading {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0

    /// Clamps a component to the range -1.0 ... 1.0
    func clamped() -> SensorReading {
        SensorReading(
            x: max(-1.0, min(1.0, x)),
            y: max(-1.0, min(1.0, y)),
            z: max(-1.0, min(1.0, z))
        )
    }
}

/// MotionManager reads accelerometer and gyroscope data and publishes
/// it as simple, normalized values for the rest of the app to use.
@MainActor
class MotionManager: ObservableObject {

    // MARK: - Published sensor readings
    // These update every ~50ms when sensors are active.

    @Published var accelerometer: SensorReading = SensorReading()
    @Published var gyroscope: SensorReading = SensorReading()

    /// True when the sensors are running, false when paused.
    @Published var isActive: Bool = false

    /// Status message for the UI.
    @Published var statusMessage: String = "Sensors inactive"

    // MARK: - Modulation routing
    // These flags control which sensor axes are "armed" as modulation sources.
    // The user can toggle them in the Sensor View.

    @Published var accelXArmed: Bool = true   // default: accel X → pitch bend CC
    @Published var accelYArmed: Bool = true   // default: accel Y → filter cutoff CC
    @Published var accelZArmed: Bool = false  // off by default
    @Published var gyroZArmed:  Bool = true   // default: gyro Z → reverb CC

    // MARK: - Private

    private let motionManager = CMMotionManager()

    /// How often to read sensor data. 0.02 = 50 times per second (50 Hz).
    /// Lowering this saves battery; raising it gives smoother motion.
    private let updateInterval: TimeInterval = 0.02

    // MARK: - Init

    init() {
        checkAvailability()
    }

    // MARK: - Availability check

    /// Check whether this device has the necessary sensors.
    private func checkAvailability() {
        let hasAccel = motionManager.isAccelerometerAvailable
        let hasGyro  = motionManager.isGyroAvailable

        if hasAccel && hasGyro {
            statusMessage = "Ready (accelerometer + gyroscope)"
        } else if hasAccel {
            statusMessage = "Accelerometer only (no gyroscope)"
        } else {
            statusMessage = "No motion sensors available on this device"
        }
    }

    // MARK: - Start / Stop

    /// Start reading sensor data.
    func start() {
        guard !isActive else { return }

        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval

        // Start accelerometer updates
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else { return }
                Task { @MainActor in
                    self.accelerometer = SensorReading(
                        x: data.acceleration.x,
                        y: data.acceleration.y,
                        z: data.acceleration.z
                    ).clamped()
                }
            }
        }

        // Start gyroscope updates
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else { return }
                Task { @MainActor in
                    self.gyroscope = SensorReading(
                        // Clamp gyro rotation rate to ±3 rad/s and normalize to -1...1
                        x: max(-1.0, min(1.0, data.rotationRate.x / 3.0)),
                        y: max(-1.0, min(1.0, data.rotationRate.y / 3.0)),
                        z: max(-1.0, min(1.0, data.rotationRate.z / 3.0))
                    )
                }
            }
        }

        isActive = true
        statusMessage = "Sensors active"
    }

    /// Stop reading sensor data (saves battery).
    func stop() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        isActive = false
        statusMessage = "Sensors paused"
    }

    /// Toggle sensors on/off.
    func toggle() {
        if isActive { stop() } else { start() }
    }

    // MARK: - Convenience: current modulation values

    /// Returns the CC value (0–127) for accelerometer X, if armed.
    var accelXCC: Int? {
        guard accelXArmed else { return nil }
        return normalizedToMIDI(accelerometer.x)
    }

    /// Returns the CC value (0–127) for accelerometer Y, if armed.
    var accelYCC: Int? {
        guard accelYArmed else { return nil }
        return normalizedToMIDI(accelerometer.y)
    }

    /// Returns the CC value (0–127) for gyroscope Z, if armed.
    var gyroZCC: Int? {
        guard gyroZArmed else { return nil }
        return normalizedToMIDI(gyroscope.z)
    }

    // MARK: - Private helper

    /// Convert a sensor value in range -1.0...1.0 to a MIDI CC value 0...127.
    private func normalizedToMIDI(_ value: Double) -> Int {
        let shifted = (value + 1.0) / 2.0          // -1...1 → 0...1
        let midi = Int((shifted * 127).rounded())   // 0...1 → 0...127
        return max(0, min(127, midi))
    }
}

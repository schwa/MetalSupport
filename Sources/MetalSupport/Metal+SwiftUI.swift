import Metal
import SwiftUI

private struct MTLDeviceKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No default Metal device found.")
        }
        return device
    }()
}

public extension EnvironmentValues {
    /// The Metal device for the current environment.
    var metalDevice: MTLDevice {
        get { self[MTLDeviceKey.self] }
        set { self[MTLDeviceKey.self] = newValue }
    }
}

private struct MTLDeviceModifier: ViewModifier {
    let value: MTLDevice
    func body(content: Content) -> some View {
        content.environment(\.metalDevice, value)
    }
}

public extension View {
    /// Sets the Metal device in the environment.
    func metalDevice(_ value: MTLDevice) -> some View {
        modifier(MTLDeviceModifier(value: value))
    }

    /// Sets the system default Metal device in the environment.
    func metalDevice() -> some View {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No default Metal device found.")
        }
        return modifier(MTLDeviceModifier(value: device))
    }
}

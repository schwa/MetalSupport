import Metal
import SwiftUI

internal struct MTLDeviceKey: EnvironmentKey {
    static var defaultValue: MTLDevice?
}

public extension EnvironmentValues {
    var metalDevice: MTLDevice? {
        get {
            self[MTLDeviceKey.self]
        }
        set {
            self[MTLDeviceKey.self] = newValue
        }
    }
}

internal struct MTLDeviceModifier: ViewModifier {
    let value: MTLDevice
    func body(content: Content) -> some View {
        content.environment(\.metalDevice, value)
    }
}

public extension View {
    func metalDevice(_ value: MTLDevice) -> some View {
        modifier(MTLDeviceModifier(value: value))
    }
    
    func metalDevice() -> some View {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Well that's just not much fun is it?")
        }
        return modifier(MTLDeviceModifier(value: device))
    }
}

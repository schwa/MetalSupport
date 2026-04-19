import Metal
@testable import MetalSupport
import SwiftUI
import Testing

@Suite("Metal + SwiftUI")
@MainActor
struct MetalSwiftUITests {
    @Test func environmentDefaultMetalDevice() {
        let env = EnvironmentValues()
        // Should return the system default device.
        #expect(env.metalDevice.name.isEmpty == false)
    }

    @Test func environmentSetMetalDevice() throws {
        var env = EnvironmentValues()
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        env.metalDevice = device
        #expect(env.metalDevice === device)
    }

    @Test func metalDeviceModifierWithDevice() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        // Just verify the modifier constructs without crashing.
        _ = Color.clear.metalDevice(device)
    }

    @Test func metalDeviceModifierDefault() {
        _ = Color.clear.metalDevice()
    }
}

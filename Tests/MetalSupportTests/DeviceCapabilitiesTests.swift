import Metal
@testable import MetalSupport
import Testing

@Test
func testSupportsMetal4MatchesGPUFamily() throws {
    let device = try #require(MTLCreateSystemDefaultDevice())
    if #available(macOS 26, iOS 26, tvOS 26, visionOS 26, *) {
        #expect(device.supportsMetal4 == device.supportsFamily(.metal4))
    } else {
        #expect(!device.supportsMetal4)
    }
}

@Test
func testParavirtualDevicesReportNoMeshShaders() throws {
    let device = try #require(MTLCreateSystemDefaultDevice())
    if device.isParavirtual {
        #expect(!device.supportsMeshShaders)
    }
}

@Test
func testMeshShaderProbeMatchesAppleSiliconFamily() throws {
    let device = try #require(MTLCreateSystemDefaultDevice())
    // Mesh shaders need Apple7 or later; the probe must not claim support below that.
    if !device.supportsFamily(.apple7), !device.supportsFamily(.mac2) {
        #expect(!device.supportsMeshShaders)
    }
}

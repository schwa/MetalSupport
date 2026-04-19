import Metal
@testable import MetalSupport
import Testing

@Suite("MTLTexture extensions")
struct TextureExtensionsTests {
    let device: MTLDevice

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
    }

    private func makeSolidBGRATexture(width: Int = 2, height: Int = 2) throws -> MTLTexture {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        desc.storageMode = .shared
        desc.usage = [.shaderRead, .shaderWrite]
        let texture = try device._makeTexture(descriptor: desc)
        let pixels: [UInt8] = Array(repeating: 128, count: width * height * 4)
        pixels.withUnsafeBytes { ptr in
            texture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: ptr.baseAddress!, bytesPerRow: width * 4)
        }
        return texture
    }

    @Test func textureToImage() throws {
        let texture = try makeSolidBGRATexture()
        _ = try texture.toImage()
    }

    @Test func textureWriteToURL() throws {
        let texture = try makeSolidBGRATexture(width: 4, height: 4)
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("MetalSupport-Test-\(UUID().uuidString).png")
        try texture.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let data = try Data(contentsOf: url)
        #expect(!data.isEmpty)
        // PNG magic bytes: 89 50 4E 47
        #expect(data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47)
    }

    @Test func srgbTextureToCGImage() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb, width: 2, height: 2, mipmapped: false)
        desc.storageMode = .shared
        desc.usage = [.shaderRead, .shaderWrite]
        let texture = try device._makeTexture(descriptor: desc)
        let pixels: [UInt8] = Array(repeating: 255, count: 2 * 2 * 4)
        pixels.withUnsafeBytes { ptr in
            texture.replace(region: MTLRegionMake2D(0, 0, 2, 2), mipmapLevel: 0, withBytes: ptr.baseAddress!, bytesPerRow: 2 * 4)
        }
        let cgImage = try texture.toCGImage()
        #expect(cgImage.width == 2)
    }
}

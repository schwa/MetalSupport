import Metal
@testable import MetalSupport
import Testing

@Suite("MTLTexture.fill")
struct TextureFillTests {
    let device: MTLDevice
    let queue: MTLCommandQueue

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
        self.queue = try device.makeCommandQueue().orThrow(.resourceCreationFailure("No command queue"))
    }

    private func makeTexture(
        width: Int = 4,
        height: Int = 4,
        pixelFormat: MTLPixelFormat = .bgra8Unorm,
        storageMode: MTLStorageMode = .shared,
        mipmapped: Bool = false
    ) throws -> MTLTexture {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: mipmapped)
        desc.storageMode = storageMode
        desc.usage = [.shaderRead, .shaderWrite]
        return try device._makeTexture(descriptor: desc)
    }

    /// Reads back pixels from a texture (via a blit to a shared texture if needed).
    private func readPixels(_ texture: MTLTexture) throws -> [UInt32] {
        let count = texture.width * texture.height
        var pixels = [UInt32](repeating: 0, count: count)
        let bytesPerRow = texture.width * 4

        #if os(macOS)
        let cpuAccessible = texture.storageMode == .shared || texture.storageMode == .managed
        #else
        let cpuAccessible = texture.storageMode == .shared
        #endif
        if cpuAccessible {
            pixels.withUnsafeMutableBytes { buffer in
                texture.getBytes(buffer.baseAddress!, bytesPerRow: bytesPerRow, from: texture.region, mipmapLevel: 0)
            }
            return pixels
        }

        // Private: blit into a shared staging texture first.
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: false)
        desc.storageMode = .shared
        desc.usage = [.shaderRead]
        let staging = try device._makeTexture(descriptor: desc)
        let cb = try queue.makeCommandBuffer().orThrow(.resourceCreationFailure("cb"))
        let enc = try cb.makeBlitCommandEncoder().orThrow(.resourceCreationFailure("enc"))
        enc.copy(from: texture, to: staging)
        enc.endEncoding()
        cb.commit()
        cb.waitUntilCompleted()
        pixels.withUnsafeMutableBytes { buffer in
            staging.getBytes(buffer.baseAddress!, bytesPerRow: bytesPerRow, from: staging.region, mipmapLevel: 0)
        }
        return pixels
    }

    @Test func fillSharedTexture() throws {
        let texture = try makeTexture()
        let color: UInt32 = 0xFF_11_22_33
        try texture.fill(with: color)
        let pixels = try readPixels(texture)
        #expect(pixels.allSatisfy { $0 == color })
    }

    @Test func fillPrivateTextureWithQueue() throws {
        let texture = try makeTexture(storageMode: .private)
        let color: UInt32 = 0xAA_BB_CC_DD
        try texture.fill(with: color, using: queue)
        let pixels = try readPixels(texture)
        #expect(pixels.allSatisfy { $0 == color })
    }

    @Test func fillPrivateTextureWithEncoder() throws {
        let texture = try makeTexture(storageMode: .private)
        let color: UInt32 = 0x01_02_03_04
        let cb = try queue.makeCommandBuffer().orThrow(.resourceCreationFailure("cb"))
        let enc = try cb.makeBlitCommandEncoder().orThrow(.resourceCreationFailure("enc"))
        try texture.fill(with: color, using: enc)
        enc.endEncoding()
        cb.commit()
        cb.waitUntilCompleted()
        let pixels = try readPixels(texture)
        #expect(pixels.allSatisfy { $0 == color })
    }

    @Test func fillStrideMismatchThrows() throws {
        let texture = try makeTexture()
        let tooSmall: UInt16 = 0x1234
        #expect(throws: MetalSupportError.self) {
            try texture.fill(with: tooSmall)
        }
    }

    @Test func fillSubRegionLeavesSurroundingPixelsUntouched() throws {
        let texture = try makeTexture(width: 4, height: 4)
        // Pre-fill with 0x00.
        let zero: UInt32 = 0
        try texture.fill(with: zero)

        // Fill only the top-left 2x2.
        let color: UInt32 = 0xFF_FF_FF_FF
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: 2, height: 2, depth: 1))
        try texture.fill(with: color, region: region)

        let pixels = try readPixels(texture)
        // Row 0: FF FF 00 00
        #expect(pixels[0] == color)
        #expect(pixels[1] == color)
        #expect(pixels[2] == 0)
        #expect(pixels[3] == 0)
        // Row 1: FF FF 00 00
        #expect(pixels[4] == color)
        #expect(pixels[5] == color)
        #expect(pixels[6] == 0)
        #expect(pixels[7] == 0)
        // Rows 2-3: all 0
        #expect(pixels[8 ..< 16].allSatisfy { $0 == 0 })
    }

    @Test func fillMipLevelOne() throws {
        let texture = try makeTexture(width: 4, height: 4, mipmapped: true)
        // mip level 1 is 2x2 = 4 pixels.
        let color: UInt32 = 0xDE_AD_BE_EF
        try texture.fill(with: color, mipmapLevel: 1)

        var mipPixels = [UInt32](repeating: 0, count: 4)
        let mipRegion = MTLRegion(origin: .zero, size: MTLSize(width: 2, height: 2, depth: 1))
        mipPixels.withUnsafeMutableBytes { buffer in
            texture.getBytes(buffer.baseAddress!, bytesPerRow: 2 * 4, from: mipRegion, mipmapLevel: 1)
        }
        #expect(mipPixels.allSatisfy { $0 == color })
    }

    // MARK: - Depth / stencil

    private func makeDepthTexture(pixelFormat: MTLPixelFormat, storageMode: MTLStorageMode = .shared) throws -> MTLTexture {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: 4, height: 4, mipmapped: false)
        desc.storageMode = storageMode
        desc.usage = [.shaderRead, .renderTarget]
        return try device._makeTexture(descriptor: desc)
    }

    private func readTypedPixels<T: BitwiseCopyable & ExpressibleByIntegerLiteral>(_ texture: MTLTexture, as _: T.Type) -> [T] {
        var pixels = [T](repeating: 0, count: texture.width * texture.height)
        pixels.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return
            }
            texture.getBytes(baseAddress, bytesPerRow: texture.width * MemoryLayout<T>.stride, from: texture.region, mipmapLevel: 0)
        }
        return pixels
    }

    @Test func fillSharedDepth32FloatTexture() throws {
        let texture = try makeDepthTexture(pixelFormat: .depth32Float)
        try texture.fill(with: Float(0.25))
        #expect(readTypedPixels(texture, as: Float.self).allSatisfy { $0 == 0.25 })
    }

    @Test func fillSharedDepth16UnormTexture() throws {
        let texture = try makeDepthTexture(pixelFormat: .depth16Unorm)
        try texture.fill(with: UInt16(0x1234))
        #expect(readTypedPixels(texture, as: UInt16.self).allSatisfy { $0 == 0x1234 })
    }

    @Test func fillSharedStencil8Texture() throws {
        let texture = try makeDepthTexture(pixelFormat: .stencil8)
        try texture.fill(with: UInt8(0x7F))
        #expect(readTypedPixels(texture, as: UInt8.self).allSatisfy { $0 == 0x7F })
    }

    @Test func fillPrivateDepth32FloatTextureWithQueue() throws {
        let texture = try makeDepthTexture(pixelFormat: .depth32Float, storageMode: .private)
        try texture.fill(with: Float(0.5), using: queue)

        let staging = try makeDepthTexture(pixelFormat: .depth32Float)
        let cb = try queue._makeCommandBuffer()
        let encoder = try cb._makeBlitCommandEncoder()
        encoder.copy(from: texture, to: staging)
        encoder.endEncoding()
        cb.commit()
        cb.waitUntilCompleted()
        #expect(readTypedPixels(staging, as: Float.self).allSatisfy { $0 == 0.5 })
    }

    @Test func fillDepthStrideMismatchThrows() throws {
        let texture = try makeDepthTexture(pixelFormat: .depth32Float)
        #expect(throws: MetalSupportError.self) {
            try texture.fill(with: UInt16(1))
        }
    }

    @Test func fillCombinedDepthStencilThrows() throws {
        let texture = try makeDepthTexture(pixelFormat: .depth32Float_stencil8)
        #expect(throws: MetalSupportError.self) {
            try texture.fill(with: UInt64(0))
        }
    }
}

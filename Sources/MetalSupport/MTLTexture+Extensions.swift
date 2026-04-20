import CoreGraphics
import ImageIO
import Metal
import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension MTLTexture {
    /// The texture dimensions as an `MTLSize`.
    var size: MTLSize {
        MTLSize(width: width, height: height, depth: depth)
    }

    /// A region covering the entire texture.
    var region: MTLRegion {
        MTLRegion(origin: .zero, size: size)
    }

    /// Converts the texture contents to a `CGImage`.
    ///
    /// Currently only supports `.bgra8Unorm` and `.bgra8Unorm_srgb` pixel formats.
    func toCGImage() throws -> CGImage {
        assert(self.pixelFormat == .bgra8Unorm || self.pixelFormat == .bgra8Unorm_srgb)
        var bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        bitmapInfo.insert(.byteOrder32Little)
        let context = try CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue).orThrow(.resourceCreationFailure("Failed to create context."))
        let data = try context.data.orThrow(.resourceCreationFailure("Failed to get context data."))
        getBytes(data, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        return try context.makeImage().orThrow(.resourceCreationFailure("Failed to create image."))
    }

    /// Converts the texture contents to a SwiftUI `Image`.
    func toImage() throws -> Image {
        #if canImport(AppKit)
        let nsImage = NSImage(cgImage: try toCGImage(), size: CGSize(width: width, height: height))
        return Image(nsImage: nsImage)
        #elseif canImport(UIKit)
        let cgImage = try toCGImage()
        let uiImage = UIImage(cgImage: cgImage)
        return Image(uiImage: uiImage)
        #endif
    }

    /// Fills a region of the texture with a repeating POD value.
    ///
    /// Uses `replace(region:...)` directly for shared/managed textures. Throws
    /// for private textures — use an overload that takes an encoder or queue.
    ///
    /// - Parameters:
    ///   - value: The POD value to repeat across every pixel in the region.
    ///   - region: The region to fill. Defaults to the entire texture at the
    ///     given mip level.
    ///   - mipmapLevel: The mip level to fill. Defaults to `0`.
    ///   - slice: The array slice / cube face to fill. Defaults to `0`.
    func fill<T>(with value: T, region: MTLRegion? = nil, mipmapLevel: Int = 0, slice: Int = 0) throws {
        precondition(isPOD(value))
        try validateFillPreconditions(valueStride: MemoryLayout<T>.stride)
        guard storageMode == .shared || storageMode == .managed else {
            throw MetalSupportError.unsupportedStorageMode("fill(with:) without an encoder/queue requires .shared or .managed storage; use the encoder or queue overload for .private textures.")
        }
        let region = region ?? mipRegion(level: mipmapLevel)
        let fill = makeFillBytes(value: value, region: region)
        fill.bytes.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError("No base address for fill buffer")
            replace(region: region, mipmapLevel: mipmapLevel, slice: slice, withBytes: baseAddress, bytesPerRow: fill.bytesPerRow, bytesPerImage: fill.bytesPerImage)
        }
    }

    /// Fills a region of the texture with a repeating POD value, using a
    /// caller-supplied blit command encoder.
    ///
    /// For `.shared` / `.managed` textures this uses `replace(region:...)`
    /// directly and does not touch the encoder. For `.private` textures it
    /// allocates a shared staging buffer sized to the region and issues a
    /// single `copy(from:sourceBuffer:...)` on the encoder.
    func fill<T>(with value: T, region: MTLRegion? = nil, mipmapLevel: Int = 0, slice: Int = 0, using encoder: MTLBlitCommandEncoder) throws {
        precondition(isPOD(value))
        try validateFillPreconditions(valueStride: MemoryLayout<T>.stride)
        let region = region ?? mipRegion(level: mipmapLevel)

        if storageMode == .shared || storageMode == .managed {
            try fill(with: value, region: region, mipmapLevel: mipmapLevel, slice: slice)
            return
        }

        guard storageMode == .private else {
            throw MetalSupportError.unsupportedStorageMode("Texture storage mode \(storageMode) is not supported by fill(with:using:).")
        }

        let device = self.device
        let fill = makeFillBytes(value: value, region: region)
        let stagingBuffer = try fill.bytes.withUnsafeBytes { buffer -> MTLBuffer in
            let baseAddress = buffer.baseAddress.orFatalError("No base address for fill buffer")
            return try device.makeBuffer(bytes: baseAddress, length: buffer.count, options: [.storageModeShared])
                .orThrow(.resourceCreationFailure("Could not create staging buffer for MTLTexture.fill."))
        }
        stagingBuffer.label = "MTLTexture.fill.staging"
        encoder.copy(
            from: stagingBuffer,
            sourceOffset: 0,
            sourceBytesPerRow: fill.bytesPerRow,
            sourceBytesPerImage: fill.bytesPerImage,
            sourceSize: region.size,
            to: self,
            destinationSlice: slice,
            destinationLevel: mipmapLevel,
            destinationOrigin: region.origin
        )
    }

    /// Fills a region of the texture with a repeating POD value, creating a
    /// command buffer and blit encoder from the given queue.
    ///
    /// The command buffer is committed and waited on before this method
    /// returns, so the texture is guaranteed filled on return.
    func fill<T>(with value: T, region: MTLRegion? = nil, mipmapLevel: Int = 0, slice: Int = 0, using queue: MTLCommandQueue) throws {
        precondition(isPOD(value))
        try validateFillPreconditions(valueStride: MemoryLayout<T>.stride)
        let region = region ?? mipRegion(level: mipmapLevel)

        if storageMode == .shared || storageMode == .managed {
            try fill(with: value, region: region, mipmapLevel: mipmapLevel, slice: slice)
            return
        }

        guard storageMode == .private else {
            throw MetalSupportError.unsupportedStorageMode("Texture storage mode \(storageMode) is not supported by fill(with:using:).")
        }

        let commandBuffer = try queue.makeCommandBuffer().orThrow(.resourceCreationFailure("Could not create command buffer for MTLTexture.fill."))
        commandBuffer.label = "MTLTexture.fill"
        let encoder = try commandBuffer.makeBlitCommandEncoder().orThrow(.resourceCreationFailure("Could not create blit encoder for MTLTexture.fill."))
        encoder.label = "MTLTexture.fill"
        try fill(with: value, region: region, mipmapLevel: mipmapLevel, slice: slice, using: encoder)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    // MARK: - Fill helpers

    /// Returns the full region for the given mip level, clamped to 1 in each
    /// dimension so mip levels beyond level 0 don't collapse to zero.
    private func mipRegion(level: Int) -> MTLRegion {
        let w = max(1, width >> level)
        let h = max(1, height >> level)
        let d = max(1, depth >> level)
        return MTLRegion(origin: .zero, size: MTLSize(width: w, height: h, depth: d))
    }

    private func validateFillPreconditions(valueStride: Int) throws {
        guard let pixelSize = pixelFormat.size else {
            throw MetalSupportError.unsupportedPixelFormat("Pixel format \(pixelFormat) has no fixed size (compressed or variable-width formats are not supported by fill()).")
        }
        // Depth/stencil formats: blit-from-buffer has extra rules; out of scope for v1.
        switch pixelFormat {
        case .depth16Unorm, .depth32Float, .stencil8, .depth24Unorm_stencil8, .depth32Float_stencil8, .x32_stencil8, .x24_stencil8:
            throw MetalSupportError.unsupportedPixelFormat("Depth/stencil pixel format \(pixelFormat) is not supported by fill().")

        default:
            break
        }
        guard valueStride == pixelSize else {
            throw MetalSupportError.invalidPixelStride("Value stride (\(valueStride)) does not match texture's bytes per pixel (\(pixelSize)) for pixel format \(pixelFormat).")
        }
    }

    /// Writes the texture contents to a PNG file at the given URL.
    func write(to url: URL) throws {
        let image = try toCGImage()
        let destination = try CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil).orThrow(.resourceCreationFailure("Failed to create image destination"))
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}

/// The result of tiling a fill value across a region.
private struct FillBytes<T> {
    var bytes: [T]
    var bytesPerRow: Int
    var bytesPerImage: Int
}

private extension MTLTexture {
    /// Builds the tiled byte buffer for a fill and returns the row/image strides.
    func makeFillBytes<T>(value: T, region: MTLRegion) -> FillBytes<T> {
        let pixelCount = region.size.width * region.size.height * region.size.depth
        let bytes = [T](repeating: value, count: pixelCount)
        let stride = MemoryLayout<T>.stride
        let bytesPerRow = region.size.width * stride
        let bytesPerImage = bytesPerRow * region.size.height
        return FillBytes(bytes: bytes, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage)
    }
}

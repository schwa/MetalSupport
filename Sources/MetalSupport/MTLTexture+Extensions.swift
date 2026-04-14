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

    /// Writes the texture contents to a PNG file at the given URL.
    func write(to url: URL) throws {
        let image = try toCGImage()
        let destination = try CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil).orThrow(.resourceCreationFailure("Failed to create image destination"))
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}

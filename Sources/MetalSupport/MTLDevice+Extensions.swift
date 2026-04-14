import Metal
import MetalKit
import simd

/// Returns the system default Metal device, or calls `fatalError` if unavailable.
public func _MTLCreateSystemDefaultDevice() -> MTLDevice {
    // swiftlint:disable:next MTLCreateSystemDefaultDevice
    MTLCreateSystemDefaultDevice().orFatalError(.unexpectedError(.resourceCreationFailure("Could not create system default device.")))
}

public extension MTLDevice {
    /// Loads a named texture from a bundle using `MTKTextureLoader`.
    ///
    /// - Parameters:
    ///   - name: The texture name in the asset catalog.
    ///   - bundle: The bundle containing the asset catalog. Defaults to `nil` (main bundle).
    /// - Returns: The loaded texture.
    func makeTexture(name: String, bundle: Bundle? = nil) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: self)
        return try textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: bundle)
    }

    /// Creates a command queue, throwing on failure.
    func _makeCommandQueue() throws -> MTLCommandQueue {
        try makeCommandQueue().orThrow(.resourceCreationFailure("Could not create command queue."))
    }

    /// Creates a sampler state from the descriptor, throwing on failure.
    func _makeSamplerState(descriptor: MTLSamplerDescriptor) throws -> MTLSamplerState {
        try makeSamplerState(descriptor: descriptor).orThrow(.resourceCreationFailure("Could not create sampler state."))
    }

    /// Creates a texture from the descriptor, throwing on failure.
    func _makeTexture(descriptor: MTLTextureDescriptor) throws -> MTLTexture {
        try makeTexture(descriptor: descriptor).orThrow(.resourceCreationFailure("Could not create texture."))
    }

    /// Creates a buffer from a POD value's raw bytes.
    func makeBuffer<T>(unsafeBytesOf value: T, options: MTLResourceOptions = []) throws -> MTLBuffer {
        precondition(isPOD(value))
        return try withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            return try makeBuffer(bytes: baseAddress, length: buffer.count, options: options).orThrow(.resourceCreationFailure("Failed to create buffer from bytes"))
        }
    }

    /// Creates a buffer from an array of POD values' raw bytes.
    func makeBuffer<T>(unsafeBytesOf value: [T], options: MTLResourceOptions = []) throws -> MTLBuffer {
        precondition(isPODArray(value))
        return try value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            return try makeBuffer(bytes: baseAddress, length: buffer.count, options: options).orThrow(.resourceCreationFailure("Failed to create buffer from array bytes"))
        }
    }

    /// Creates a buffer from a collection with contiguous storage.
    func makeBuffer<C>(collection: C, options: MTLResourceOptions) throws -> MTLBuffer where C: Collection {
        assert(isPOD(C.Element.self))
        let buffer = try collection.withContiguousStorageIfAvailable { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            let baseAddress = raw.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            guard let buffer = makeBuffer(bytes: baseAddress, length: raw.count, options: options) else {
                throw MetalSupportError.resourceCreationFailure("MTLDevice.makeBuffer failed.")
            }
            return buffer
        }
        guard let buffer else {
            fatalError("No contiguous storage available.")
        }
        return buffer
    }

    /// Creates a texture filled with a repeating value.
    func makeTexture<T>(descriptor: MTLTextureDescriptor, repeating value: T) throws -> MTLTexture {
        assert(isPOD(value))
        let numPixels = descriptor.width * descriptor.height
        let values = [T](repeating: value, count: numPixels)
        let texture = try _makeTexture(descriptor: descriptor)
        values.withUnsafeBufferPointer { buffer in
            let buffer = UnsafeRawBufferPointer(buffer)
            let baseAddress = buffer.baseAddress.orFatalError("No base address for texture data")
            texture.replace(region: MTLRegionMake2D(0, 0, descriptor.width, descriptor.height), mipmapLevel: 0, withBytes: baseAddress, bytesPerRow: descriptor.width * MemoryLayout<T>.stride)
        }
        return texture
    }

    /// Creates a 1×1 RGBA8 texture with the given color.
    ///
    /// - Parameter color: The fill color as normalized floats (0–1).
    func make1PixelTexture(color: SIMD4<Float>) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1, height: 1, mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        descriptor.storageMode = .shared
        let value = SIMD4<UInt8>(color * 255.0)
        return try makeTexture(descriptor: descriptor, repeating: value)
    }
}

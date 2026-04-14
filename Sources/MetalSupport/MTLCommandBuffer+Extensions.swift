import Metal

public extension MTLCommandBuffer {
    /// Creates a blit command encoder, throwing on failure.
    func _makeBlitCommandEncoder() throws -> MTLBlitCommandEncoder {
        try makeBlitCommandEncoder().orThrow(.resourceCreationFailure("Could not create blit command encoder."))
    }

    /// Creates a compute command encoder, throwing on failure.
    func _makeComputeCommandEncoder() throws -> MTLComputeCommandEncoder {
        try makeComputeCommandEncoder().orThrow(.resourceCreationFailure("Could not create compute command encoder."))
    }

    /// Creates a render command encoder, throwing on failure.
    func _makeRenderCommandEncoder(descriptor: MTLRenderPassDescriptor) throws -> MTLRenderCommandEncoder {
        try makeRenderCommandEncoder(descriptor: descriptor).orThrow(.resourceCreationFailure("Could not create render command encoder."))
    }

    /// Creates a render command encoder, executes `block`, then ends encoding.
    ///
    /// - Parameters:
    ///   - descriptor: The render pass descriptor.
    ///   - block: A closure that receives the encoder.
    /// - Returns: The value returned by `block`.
    func withRenderCommandEncoder<R>(descriptor: MTLRenderPassDescriptor, block: (MTLRenderCommandEncoder) throws -> R) rethrows -> R {
        guard let renderCommandEncoder = makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Failed to make render command encoder.")
        }
        defer {
            renderCommandEncoder.endEncoding()
        }
        return try block(renderCommandEncoder)
    }
}

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
}

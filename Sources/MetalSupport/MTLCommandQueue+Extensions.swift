import Metal

public extension MTLCommandQueue {
    /// Creates a command buffer, throwing on failure.
    func _makeCommandBuffer() throws -> MTLCommandBuffer {
        try makeCommandBuffer().orThrow(.resourceCreationFailure("Could not create command buffer."))
    }

    /// Creates a command buffer from the descriptor, throwing on failure.
    func _makeCommandBuffer(descriptor: MTLCommandBufferDescriptor) throws -> MTLCommandBuffer {
        try makeCommandBuffer(descriptor: descriptor).orThrow(.resourceCreationFailure("Could not create command buffer."))
    }
}

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

    /// Creates a command buffer, executes `block`, then commits.
    ///
    /// - Parameters:
    ///   - wait: Whether to block until the command buffer completes.
    ///   - block: A closure that receives the command buffer.
    /// - Returns: The value returned by `block`.
    func withCommandBuffer<R>(waitAfterCommit wait: Bool, block: (MTLCommandBuffer) throws -> R) rethrows -> R {
        guard let commandBuffer = makeCommandBuffer() else {
            fatalError("Failed to make command buffer.")
        }
        defer {
            commandBuffer.commit()
            if wait {
                commandBuffer.waitUntilCompleted()
            }
        }
        return try block(commandBuffer)
    }

    /// Creates a command buffer, executes `block`, presents the drawable, then commits.
    ///
    /// - Parameters:
    ///   - drawable: An autoclosure that returns the drawable to present, or `nil`.
    ///   - block: A closure that receives the command buffer.
    /// - Returns: The value returned by `block`.
    func withCommandBuffer<R>(drawable: @autoclosure () -> (any MTLDrawable)?, block: (MTLCommandBuffer) throws -> R) rethrows -> R {
        guard let commandBuffer = makeCommandBuffer() else {
            fatalError("Failed to make command buffer.")
        }
        defer {
            if let drawable = drawable() {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }
        return try block(commandBuffer)
    }
}

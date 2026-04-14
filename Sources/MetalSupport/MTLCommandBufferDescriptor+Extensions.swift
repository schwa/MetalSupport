import Metal

/// Describes how a command buffer should be completed after recording.
public enum MTLCommandQueueCompletion {
    /// Do not commit the command buffer.
    case none
    /// Commit the command buffer.
    case commit
    /// Commit and block until execution finishes.
    case commitAndWaitUntilCompleted
}

public extension MTLCommandBufferDescriptor {
    /// Attaches a default log state for Metal shader logging.
    func addDefaultLogging() throws {
        let logStateDescriptor = MTLLogStateDescriptor()
        logStateDescriptor.bufferSize = 32 * 1_024 * 1_024
        let device = _MTLCreateSystemDefaultDevice()
        let logState = try device.makeLogState(descriptor: logStateDescriptor)
        logState.addLogHandler { _, _, _, _ in
        }
        self.logState = logState
    }
}

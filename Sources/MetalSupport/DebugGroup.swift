import Metal

public extension MTLCaptureManager {
    /// Executes a closure inside a GPU capture scope.
    ///
    /// - Parameters:
    ///   - enabled: When `false`, the body executes without capturing. Defaults to `true`.
    ///   - body: The work to capture.
    /// - Returns: The value returned by `body`.
    func with<R>(enabled: Bool = true, _ body: () throws -> R) throws -> R {
        guard enabled else {
            return try body()
        }
        let device = _MTLCreateSystemDefaultDevice()
        let captureScope = makeCaptureScope(device: device)
        let captureDescriptor = MTLCaptureDescriptor()
        captureDescriptor.captureObject = captureScope
        try startCapture(with: captureDescriptor)
        captureScope.begin()
        defer {
            captureScope.end()
        }
        return try body()
    }
}

public extension MTLCommandBuffer {
    /// Pushes a debug group for the duration of `body`, then pops it.
    ///
    /// - Parameters:
    ///   - enabled: When `false`, the body executes without a debug group.
    ///   - label: The debug group label.
    ///   - body: The work to execute inside the debug group.
    func withDebugGroup<R>(enabled: Bool = true, _ label: String, _ body: () throws -> R) rethrows -> R {
        guard enabled else {
            return try body()
        }
        pushDebugGroup(label)
        defer {
            popDebugGroup()
        }
        return try body()
    }
}

public extension MTLRenderCommandEncoder {
    /// Pushes a debug group for the duration of `body`, then pops it.
    func withDebugGroup<R>(enabled: Bool = true, _ label: String, _ body: () throws -> R) rethrows -> R {
        guard enabled else {
            return try body()
        }
        pushDebugGroup(label)
        defer {
            popDebugGroup()
        }
        return try body()
    }
}

public extension MTLComputeCommandEncoder {
    /// Pushes a debug group for the duration of `body`, then pops it.
    func withDebugGroup<R>(enabled: Bool = true, _ label: String, _ body: () throws -> R) rethrows -> R {
        guard enabled else {
            return try body()
        }
        pushDebugGroup(label)
        defer {
            popDebugGroup()
        }
        return try body()
    }
}

public extension MTLBlitCommandEncoder {
    /// Pushes a debug group for the duration of `body`, then pops it.
    func withDebugGroup<R>(enabled: Bool = true, label: String, _ body: () throws -> R) rethrows -> R {
        guard enabled else {
            return try body()
        }
        pushDebugGroup(label)
        defer {
            popDebugGroup()
        }
        return try body()
    }
}

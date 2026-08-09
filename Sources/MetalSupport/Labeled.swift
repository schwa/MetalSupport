import Metal

// Metal's labelled types share no common protocol, so `labeled(_:)` is provided on the widest
// available ancestors: MTLResource (textures, buffers, heaps, ...) and MTLCommandEncoder (all
// encoder flavours), plus command queues and command buffers individually.

public extension MTLResource {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

public extension MTLCommandEncoder {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

public extension MTLCommandQueue {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

public extension MTLCommandBuffer {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

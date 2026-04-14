import Metal

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

public extension MTLRenderCommandEncoder {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

public extension MTLTexture {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

public extension MTLBuffer {
    /// Sets the label and returns `self` for chaining.
    func labeled(_ label: String) -> Self {
        self.label = label
        return self
    }
}

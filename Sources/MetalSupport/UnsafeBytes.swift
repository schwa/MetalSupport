import Metal

// MARK: - Raw byte helpers

// Metal's setXxxBytes(_:length:index:) family all want a base address plus a byte count.
// These two helpers hold that pattern so the encoder extensions below stay one-liners.

private func withRawBytes<T: BitwiseCopyable, R>(of value: T, _ body: (UnsafeRawPointer, Int) throws -> R) rethrows -> R {
    try withUnsafeBytes(of: value) { buffer in
        let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
        return try body(baseAddress, MemoryLayout<T>.stride)
    }
}

private func withRawBytes<T: BitwiseCopyable, R>(of values: [T], _ body: (UnsafeRawPointer, Int) throws -> R) rethrows -> R {
    try values.withUnsafeBytes { buffer in
        let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
        return try body(baseAddress, MemoryLayout<T>.stride * values.count)
    }
}

// MARK: - Argument encoder

public extension MTLArgumentEncoder {
    /// Copies a value's raw bytes into the argument buffer at the given index.
    func setBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        withUnsafeBytes(of: value) { buffer in
            let dest = UnsafeMutableRawBufferPointer(start: constantData(at: index), count: encodedLength)
            buffer.copyBytes(to: dest)
        }
    }
}

// MARK: - Render command encoder: per-stage setters

public extension MTLRenderCommandEncoder {
    /// Sets vertex bytes from an array's raw storage.
    func setVertexUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setVertexBytes(pointer, length: length, index: index)
        }
    }

    /// Sets vertex bytes from a value's raw storage.
    func setVertexUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setVertexBytes(pointer, length: length, index: index)
        }
    }

    /// Sets fragment bytes from an array's raw storage.
    func setFragmentUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setFragmentBytes(pointer, length: length, index: index)
        }
    }

    /// Sets fragment bytes from a value's raw storage.
    func setFragmentUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setFragmentBytes(pointer, length: length, index: index)
        }
    }

    /// Sets object bytes from an array's raw storage.
    func setObjectUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setObjectBytes(pointer, length: length, index: index)
        }
    }

    /// Sets object bytes from a value's raw storage.
    func setObjectUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setObjectBytes(pointer, length: length, index: index)
        }
    }

    /// Sets mesh bytes from an array's raw storage.
    func setMeshUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setMeshBytes(pointer, length: length, index: index)
        }
    }

    /// Sets mesh bytes from a value's raw storage.
    func setMeshUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setMeshBytes(pointer, length: length, index: index)
        }
    }
}

// MARK: - Render command encoder: function-type dispatch

public extension MTLRenderCommandEncoder {
    /// Sets bytes for the specified function type from an array's raw storage.
    func setUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int, functionType: MTLFunctionType) {
        precondition(index >= 0)
        switch functionType {
        case .vertex: setVertexUnsafeBytes(of: value, index: index)
        case .fragment: setFragmentUnsafeBytes(of: value, index: index)
        case .object: setObjectUnsafeBytes(of: value, index: index)
        case .mesh: setMeshUnsafeBytes(of: value, index: index)
        default: fatalError("Unimplemented")
        }
    }

    /// Sets bytes for the specified function type from a value's raw storage.
    func setUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int, functionType: MTLFunctionType) {
        precondition(index >= 0)
        switch functionType {
        case .vertex: setVertexUnsafeBytes(of: value, index: index)
        case .fragment: setFragmentUnsafeBytes(of: value, index: index)
        case .object: setObjectUnsafeBytes(of: value, index: index)
        case .mesh: setMeshUnsafeBytes(of: value, index: index)
        default: fatalError("Unimplemented")
        }
    }

    /// Sets a buffer for the specified function type.
    func setBuffer(_ buffer: MTLBuffer?, offset: Int, index: Int, functionType: MTLFunctionType) {
        switch functionType {
        case .vertex: setVertexBuffer(buffer, offset: offset, index: index)
        case .fragment: setFragmentBuffer(buffer, offset: offset, index: index)
        case .object: setObjectBuffer(buffer, offset: offset, index: index)
        case .mesh: setMeshBuffer(buffer, offset: offset, index: index)
        default: fatalError("Unimplemented")
        }
    }

    /// Sets a texture for the specified function type.
    func setTexture(_ texture: MTLTexture?, index: Int, functionType: MTLFunctionType) {
        switch functionType {
        case .vertex: setVertexTexture(texture, index: index)
        case .fragment: setFragmentTexture(texture, index: index)
        case .object: setObjectTexture(texture, index: index)
        case .mesh: setMeshTexture(texture, index: index)
        default: fatalError("Unimplemented")
        }
    }

    /// Sets a sampler state for the specified function type.
    func setSamplerState(_ sampler: MTLSamplerState?, index: Int, functionType: MTLFunctionType) {
        switch functionType {
        case .vertex: setVertexSamplerState(sampler, index: index)
        case .fragment: setFragmentSamplerState(sampler, index: index)
        case .object: setObjectSamplerState(sampler, index: index)
        case .mesh: setMeshSamplerState(sampler, index: index)
        default: fatalError("Unimplemented")
        }
    }
}

// MARK: - Compute command encoder

public extension MTLComputeCommandEncoder {
    /// Sets compute bytes from an array's raw storage.
    func setUnsafeBytes<T: BitwiseCopyable>(of value: [T], index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setBytes(pointer, length: length, index: index)
        }
    }

    /// Sets compute bytes from a value's raw storage.
    func setUnsafeBytes<T: BitwiseCopyable>(of value: T, index: Int) {
        precondition(index >= 0)
        withRawBytes(of: value) { pointer, length in
            setBytes(pointer, length: length, index: index)
        }
    }
}

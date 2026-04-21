import Metal

// MARK: - Argument encoder

public extension MTLArgumentEncoder {
    /// Copies a value's raw bytes into the argument buffer at the given index.
    func setBytes<T>(of value: T, index: Int) {
        withUnsafeBytes(of: value) { buffer in
            let dest = UnsafeMutableRawBufferPointer(start: constantData(at: index), count: encodedLength)
            buffer.copyBytes(to: dest)
        }
    }
}

// MARK: - Render command encoder: per-stage setters

public extension MTLRenderCommandEncoder {
    /// Sets vertex bytes from an array's raw storage.
    func setVertexUnsafeBytes<T>(of value: [T], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setVertexBytes(baseAddress, length: MemoryLayout<T>.stride * value.count, index: index)
        }
    }

    /// Sets vertex bytes from a value's raw storage.
    func setVertexUnsafeBytes<T>(of value: T, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setVertexBytes(baseAddress, length: MemoryLayout<T>.stride, index: index)
        }
    }

    /// Sets fragment bytes from an array's raw storage.
    func setFragmentUnsafeBytes<T>(of value: [T], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setFragmentBytes(baseAddress, length: MemoryLayout<T>.stride * value.count, index: index)
        }
    }

    /// Sets fragment bytes from a value's raw storage.
    func setFragmentUnsafeBytes<T>(of value: T, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setFragmentBytes(baseAddress, length: MemoryLayout<T>.stride, index: index)
        }
    }

    /// Sets object bytes from an array's raw storage.
    func setObjectUnsafeBytes<T>(of value: [T], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setObjectBytes(baseAddress, length: MemoryLayout<T>.stride * value.count, index: index)
        }
    }

    /// Sets object bytes from a value's raw storage.
    func setObjectUnsafeBytes<T>(of value: T, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setObjectBytes(baseAddress, length: MemoryLayout<T>.stride, index: index)
        }
    }

    /// Sets mesh bytes from an array's raw storage.
    func setMeshUnsafeBytes<T>(of value: [T], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setMeshBytes(baseAddress, length: MemoryLayout<T>.stride * value.count, index: index)
        }
    }

    /// Sets mesh bytes from a value's raw storage.
    func setMeshUnsafeBytes<T>(of value: T, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setMeshBytes(baseAddress, length: MemoryLayout<T>.stride, index: index)
        }
    }
}

// MARK: - Render command encoder: function-type dispatch

public extension MTLRenderCommandEncoder {
    /// Sets bytes for the specified function type from an array's raw storage.
    func setUnsafeBytes<T>(of value: [T], index: Int, functionType: MTLFunctionType) {
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
    func setUnsafeBytes<T>(of value: T, index: Int, functionType: MTLFunctionType) {
        precondition(index >= 0)
        assert(isPOD(value))
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
    func setUnsafeBytes<T>(of value: [T], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setBytes(baseAddress, length: MemoryLayout<T>.stride * value.count, index: index)
        }
    }

    /// Sets compute bytes from a value's raw storage.
    func setUnsafeBytes<T>(of value: T, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setBytes(baseAddress, length: MemoryLayout<T>.stride, index: index)
        }
    }
}

import Metal

// MARK: - Render command encoder: per-stage setters

public extension MTLRenderCommandEncoder {
    /// Sets vertex bytes from an array's raw storage.
    func setVertexUnsafeBytes(of value: [some Any], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setVertexBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets vertex bytes from a value's raw storage.
    func setVertexUnsafeBytes(of value: some Any, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setVertexBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets fragment bytes from an array's raw storage.
    func setFragmentUnsafeBytes(of value: [some Any], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setFragmentBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets fragment bytes from a value's raw storage.
    func setFragmentUnsafeBytes(of value: some Any, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setFragmentBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets object bytes from an array's raw storage.
    func setObjectUnsafeBytes(of value: [some Any], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setObjectBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets object bytes from a value's raw storage.
    func setObjectUnsafeBytes(of value: some Any, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setObjectBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets mesh bytes from an array's raw storage.
    func setMeshUnsafeBytes(of value: [some Any], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setMeshBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets mesh bytes from a value's raw storage.
    func setMeshUnsafeBytes(of value: some Any, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setMeshBytes(baseAddress, length: buffer.count, index: index)
        }
    }
}

// MARK: - Render command encoder: function-type dispatch

public extension MTLRenderCommandEncoder {
    /// Sets bytes for the specified function type from an array's raw storage.
    func setUnsafeBytes(of value: [some Any], index: Int, functionType: MTLFunctionType) {
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
    func setUnsafeBytes(of value: some Any, index: Int, functionType: MTLFunctionType) {
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
    func setUnsafeBytes(of value: [some Any], index: Int) {
        precondition(index >= 0)
        value.withUnsafeBytes { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setBytes(baseAddress, length: buffer.count, index: index)
        }
    }

    /// Sets compute bytes from a value's raw storage.
    func setUnsafeBytes(of value: some Any, index: Int) {
        precondition(index >= 0)
        assert(isPOD(value))
        withUnsafeBytes(of: value) { buffer in
            let baseAddress = buffer.baseAddress.orFatalError(.resourceCreationFailure("No base address."))
            setBytes(baseAddress, length: buffer.count, index: index)
        }
    }
}

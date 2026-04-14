import Metal

public extension MTLArgumentDescriptor {
    /// Creates an argument descriptor with the given parameters.
    @available(iOS 17, macOS 14, *)
    convenience init(dataType: MTLDataType, index: Int, arrayLength: Int? = nil, access: MTLBindingAccess? = nil, textureType: MTLTextureType? = nil, constantBlockAlignment: Int? = nil) {
        self.init()
        self.dataType = dataType
        self.index = index
        if let arrayLength {
            self.arrayLength = arrayLength
        }
        if let access {
            self.access = access
        }
        if let textureType {
            self.textureType = textureType
        }
        if let constantBlockAlignment {
            self.arrayLength = constantBlockAlignment
        }
    }
}

public extension MTLAttributeDescriptor {
    /// Creates an attribute descriptor with the given format, offset, and buffer index.
    convenience init(format: MTLAttributeFormat, offset: Int = 0, bufferIndex: Int) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}

public extension MTLDepthStencilDescriptor {
    /// Creates a depth-stencil descriptor with the given compare function.
    convenience init(depthCompareFunction: MTLCompareFunction, isDepthWriteEnabled: Bool = true) {
        self.init()
        self.depthCompareFunction = depthCompareFunction
        self.isDepthWriteEnabled = isDepthWriteEnabled
    }

    /// Creates a depth-stencil descriptor with the given depth-write setting.
    convenience init(isDepthWriteEnabled: Bool = true) {
        self.init()
        self.isDepthWriteEnabled = isDepthWriteEnabled
    }

    /// Creates a depth-stencil descriptor with full control over depth, stencil, and label.
    convenience init(depthCompareFunction: MTLCompareFunction = .less, isDepthWriteEnabled: Bool = true, frontFaceStencil: MTLStencilDescriptor? = nil, backFaceStencil: MTLStencilDescriptor? = nil, label: String? = nil) {
        self.init()
        self.depthCompareFunction = depthCompareFunction
        self.isDepthWriteEnabled = isDepthWriteEnabled
        if let frontFaceStencil {
            self.frontFaceStencil = frontFaceStencil
        }
        if let backFaceStencil {
            self.backFaceStencil = backFaceStencil
        }
        if let label {
            self.label = label
        }
    }
}

public extension MTLStencilDescriptor {
    /// Creates a stencil descriptor with the given operations and masks.
    convenience init(compareFunction: MTLCompareFunction = .always, stencilFailureOperation: MTLStencilOperation = .keep, depthFailureOperation: MTLStencilOperation = .keep, stencilPassDepthPassOperation: MTLStencilOperation = .keep, readMask: UInt32 = 0xffffffff, writeMask: UInt32 = 0xffffffff) {
        self.init()
        self.stencilCompareFunction = compareFunction
        self.stencilFailureOperation = stencilFailureOperation
        self.depthFailureOperation = depthFailureOperation
        self.depthStencilPassOperation = stencilPassDepthPassOperation
        self.readMask = readMask
        self.writeMask = writeMask
    }
}

public extension MTLSamplerDescriptor {
    // swiftlint:disable discouraged_optional_boolean
    /// Creates a sampler descriptor with the given filtering and addressing parameters.
    ///
    /// All parameters are optional; only non-nil values override the defaults.
    // swiftlint:disable:next cyclomatic_complexity
    convenience init(minFilter: MTLSamplerMinMagFilter? = nil, magFilter: MTLSamplerMinMagFilter? = nil, mipFilter: MTLSamplerMipFilter? = nil, maxAnisotropy: Int? = nil, sAddressMode: MTLSamplerAddressMode? = nil, tAddressMode: MTLSamplerAddressMode? = nil, rAddressMode: MTLSamplerAddressMode? = nil, borderColor: MTLSamplerBorderColor? = nil, normalizedCoordinates: Bool? = nil, lodMinClamp: Float? = nil, lodMaxClamp: Float? = nil, lodAverage: Bool? = nil, compareFunction: MTLCompareFunction? = nil, supportArgumentBuffers: Bool? = nil, label: String? = nil) {
        // swiftlint:enable discouraged_optional_boolean
        self.init()
        if let minFilter {
            self.minFilter = minFilter
        }
        if let magFilter {
            self.magFilter = magFilter
        }
        if let mipFilter {
            self.mipFilter = mipFilter
        }
        if let maxAnisotropy {
            self.maxAnisotropy = maxAnisotropy
        }
        if let sAddressMode {
            self.sAddressMode = sAddressMode
        }
        if let tAddressMode {
            self.tAddressMode = tAddressMode
        }
        if let rAddressMode {
            self.rAddressMode = rAddressMode
        }
        if let borderColor {
            self.borderColor = borderColor
        }
        if let normalizedCoordinates {
            self.normalizedCoordinates = normalizedCoordinates
        }
        if let lodMinClamp {
            self.lodMinClamp = lodMinClamp
        }
        if let lodMaxClamp {
            self.lodMaxClamp = lodMaxClamp
        }
        if let lodAverage {
            self.lodAverage = lodAverage
        }
        if let compareFunction {
            self.compareFunction = compareFunction
        }
        if let supportArgumentBuffers {
            self.supportArgumentBuffers = supportArgumentBuffers
        }
        if let label {
            self.label = label
        }
    }
}

import Metal

public extension MTLIndexType {
    /// The byte size of a single index element.
    var indexSize: Int {
        switch self {
        case .uint16:
            return MemoryLayout<UInt16>.size
        case .uint32:
            return MemoryLayout<UInt32>.size
        @unknown default:
            fatalError("Unknown MTLIndexType")
        }
    }
}

public extension MTLPrimitiveType {
    /// The number of vertices per primitive, or `nil` for variable-count types.
    var vertexCount: Int? {
        switch self {
        case .point:
            return 1
        case .line:
            return 2
        case .triangle:
            return 3
        case .lineStrip, .triangleStrip:
            return nil
        @unknown default:
            return nil
        }
    }
}

import CoreGraphics
import Metal

public extension MTLOrigin {
    /// The origin at (0, 0, 0).
    static var zero: MTLOrigin {
        MTLOrigin(x: 0, y: 0, z: 0)
    }

    /// Creates an origin from a `CGPoint`, with depth 0.
    init(_ origin: CGPoint) {
        self.init(x: Int(origin.x), y: Int(origin.y), z: 0)
    }
}

public extension MTLSize {
    /// Creates a size from individual components.
    init(_ width: Int, _ height: Int, _ depth: Int) {
        self = MTLSize(width: width, height: height, depth: depth)
    }

    /// Creates a size from a `CGSize`, with depth 1.
    init(_ size: CGSize) {
        self.init(width: Int(size.width), height: Int(size.height), depth: 1)
    }
}

public extension MTLRegion {
    /// Creates a region from a `CGRect`, with depth 1.
    init(_ rect: CGRect) {
        self = MTLRegion(origin: MTLOrigin(rect.origin), size: MTLSize(rect.size))
    }
}

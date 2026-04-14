import Metal

public extension MTLBuffer {
    /// Returns the buffer contents as a raw buffer pointer.
    func contentsBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: contents(), count: length)
    }

    /// Returns the buffer contents bound to the specified type.
    func contents<T>() -> UnsafeBufferPointer<T> {
        contentsBuffer().bindMemory(to: T.self)
    }

    /// Returns the GPU address as an `UnsafeMutablePointer` to the given type.
    ///
    /// Only valid on 64-bit platforms.
    func gpuAddressAsUnsafeMutablePointer<T>(type: T.Type) -> UnsafeMutablePointer<T>? {
        precondition(MemoryLayout<Int>.stride == MemoryLayout<UInt64>.stride)
        let bits = Int(Int64(bitPattern: gpuAddress))
        return UnsafeMutablePointer<T>(bitPattern: bits)
    }
}

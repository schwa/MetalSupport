import Foundation
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
    func gpuAddressAsUnsafeMutablePointer<T>(type _: T.Type) -> UnsafeMutablePointer<T>? {
        precondition(MemoryLayout<Int>.stride == MemoryLayout<UInt64>.stride)
        let bits = Int(Int64(bitPattern: gpuAddress))
        return UnsafeMutablePointer<T>(bitPattern: bits)
    }

    /// Returns the buffer contents as `Data`.
    func data() -> Data {
        Data(bytes: contents(), count: length)
    }

    /// Provides mutable access to the buffer contents as a typed pointer.
    ///
    /// - Parameters:
    ///   - type: The type to bind the contents to.
    ///   - block: A closure that receives an `inout` reference to the value.
    /// - Returns: The value returned by `block`.
    func with<T, R>(type _: T.Type, _ block: (inout T) -> R) -> R {
        let value = contents().bindMemory(to: T.self, capacity: 1)
        return block(&value.pointee)
    }

    /// Provides mutable access to the buffer contents as a typed buffer pointer.
    ///
    /// - Parameters:
    ///   - type: The element type to bind the contents to.
    ///   - count: The number of elements.
    ///   - block: A closure that receives the mutable buffer pointer.
    /// - Returns: The value returned by `block`.
    func withEx<T, R>(type _: T.Type, count: Int, _ block: (UnsafeMutableBufferPointer<T>) -> R) -> R {
        let pointer = contents().bindMemory(to: T.self, capacity: count)
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: count)
        return block(buffer)
    }
}

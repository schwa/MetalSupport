import Metal
import MetalKit
import ModelIO
import simd

public extension MTLVertexDescriptor {
    /// Creates a vertex descriptor by packing the given vertex attributes sequentially into buffer 0.
    ///
    /// - Parameter vertexAttributes: The attributes to pack. Offsets are computed automatically using packed sizes.
    convenience init(vertexAttributes: [MTLVertexAttribute]) {
        self.init()
        var offset: Int = 0
        for (index, attribute) in vertexAttributes.enumerated() {
            let format = MTLVertexFormat(attribute.attributeType)
            attributes[index].format = format
            attributes[index].bufferIndex = 0
            attributes[index].offset = offset
            offset += format.size(packed: true)
        }
        layouts[0].stride = offset
    }

    /// Creates a vertex descriptor from an `MDLVertexDescriptor`.
    convenience init(_ vertexDescriptor: MDLVertexDescriptor) {
        self.init()
        // swiftlint:disable:next force_cast
        for (index, attribute) in vertexDescriptor.attributes.map({ $0 as! MDLVertexAttribute }).enumerated() {
            self.attributes[index].format = MTLVertexFormat(attribute.format)
            self.attributes[index].offset = attribute.offset
            self.attributes[index].bufferIndex = attribute.bufferIndex
        }
        // swiftlint:disable:next force_cast
        for (index, layout) in vertexDescriptor.layouts.map({ $0 as! MDLVertexBufferLayout }).enumerated() {
            self.layouts[index].stride = layout.stride
        }
    }

    /// Creates a vertex descriptor by reflecting over the stored properties of a POD struct.
    ///
    /// Each field becomes a vertex attribute in buffer 0. The struct must be plain-old-data.
    convenience init<T>(reflection _: T.Type) {
        self.init()

        assert(_isPOD(T.self))

        let raw = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        let mirror = raw.withUnsafeBufferPointer { buf in
            buf.withMemoryRebound(to: T.self) { reb in
                Mirror(reflecting: reb[0])
            }
        }

        var offset = 0

        func writeAttribute(format: MTLVertexFormat, size: Int, alignment: Int, i: Int) -> Int {
            offset = _align(offset, to: alignment)
            attributes[i].format = format
            attributes[i].offset = offset
            attributes[i].bufferIndex = 0
            return size
        }

        for (i, child) in mirror.children.enumerated() {
            switch child.value {
            case is Float:
                offset += writeAttribute(format: .float, size: MemoryLayout<Float>.size, alignment: MemoryLayout<Float>.alignment, i: i)
            case is SIMD2<Float>:
                offset += writeAttribute(format: .float2, size: MemoryLayout<SIMD2<Float>>.size, alignment: MemoryLayout<SIMD2<Float>>.alignment, i: i)
            case is SIMD3<Float>:
                offset += writeAttribute(format: .float3, size: MemoryLayout<SIMD3<Float>>.size, alignment: MemoryLayout<SIMD3<Float>>.alignment, i: i)
            case is SIMD4<Float>:
                offset += writeAttribute(format: .float4, size: MemoryLayout<SIMD4<Float>>.size, alignment: MemoryLayout<SIMD4<Float>>.alignment, i: i)
            case is UInt8:
                offset += writeAttribute(format: .uchar, size: MemoryLayout<UInt8>.size, alignment: MemoryLayout<UInt8>.alignment, i: i)
            case is SIMD2<UInt8>:
                offset += writeAttribute(format: .uchar2Normalized, size: MemoryLayout<SIMD2<UInt8>>.size, alignment: MemoryLayout<SIMD2<UInt8>>.alignment, i: i)
            case is SIMD3<UInt8>:
                offset += writeAttribute(format: .uchar3Normalized, size: MemoryLayout<SIMD3<UInt8>>.size, alignment: MemoryLayout<SIMD3<UInt8>>.alignment, i: i)
            case is SIMD4<UInt8>:
                offset += writeAttribute(format: .uchar4Normalized, size: MemoryLayout<SIMD4<UInt8>>.size, alignment: MemoryLayout<SIMD4<UInt8>>.alignment, i: i)
            case is Int8:
                offset += writeAttribute(format: .char, size: MemoryLayout<Int8>.size, alignment: MemoryLayout<Int8>.alignment, i: i)
            case is SIMD2<Int8>:
                offset += writeAttribute(format: .char2, size: MemoryLayout<SIMD2<Int8>>.size, alignment: MemoryLayout<SIMD2<Int8>>.alignment, i: i)
            case is SIMD3<Int8>:
                offset += writeAttribute(format: .char3, size: MemoryLayout<SIMD3<Int8>>.size, alignment: MemoryLayout<SIMD3<Int8>>.alignment, i: i)
            case is SIMD4<Int8>:
                offset += writeAttribute(format: .char4, size: MemoryLayout<SIMD4<Int8>>.size, alignment: MemoryLayout<SIMD4<Int8>>.alignment, i: i)
            case is UInt16:
                offset += writeAttribute(format: .ushort, size: MemoryLayout<UInt16>.size, alignment: MemoryLayout<UInt16>.alignment, i: i)
            case is SIMD2<UInt16>:
                offset += writeAttribute(format: .ushort2, size: MemoryLayout<SIMD2<UInt16>>.size, alignment: MemoryLayout<SIMD2<UInt16>>.alignment, i: i)
            case is SIMD3<UInt16>:
                offset += writeAttribute(format: .ushort3, size: MemoryLayout<SIMD3<UInt16>>.size, alignment: MemoryLayout<SIMD3<UInt16>>.alignment, i: i)
            case is SIMD4<UInt16>:
                offset += writeAttribute(format: .ushort4, size: MemoryLayout<SIMD4<UInt16>>.size, alignment: MemoryLayout<SIMD4<UInt16>>.alignment, i: i)
            case is Int16:
                offset += writeAttribute(format: .short, size: MemoryLayout<Int16>.size, alignment: MemoryLayout<Int16>.alignment, i: i)
            case is SIMD2<Int16>:
                offset += writeAttribute(format: .short2, size: MemoryLayout<SIMD2<Int16>>.size, alignment: MemoryLayout<SIMD2<Int16>>.alignment, i: i)
            case is SIMD3<Int16>:
                offset += writeAttribute(format: .short3, size: MemoryLayout<SIMD3<Int16>>.size, alignment: MemoryLayout<SIMD3<Int16>>.alignment, i: i)
            case is SIMD4<Int16>:
                offset += writeAttribute(format: .short4, size: MemoryLayout<SIMD4<Int16>>.size, alignment: MemoryLayout<SIMD4<Int16>>.alignment, i: i)
            case is UInt32:
                offset += writeAttribute(format: .uint, size: MemoryLayout<UInt32>.size, alignment: MemoryLayout<UInt32>.alignment, i: i)
            case is SIMD2<UInt32>:
                offset += writeAttribute(format: .uint2, size: MemoryLayout<SIMD2<UInt32>>.size, alignment: MemoryLayout<SIMD2<UInt32>>.alignment, i: i)
            case is SIMD3<UInt32>:
                offset += writeAttribute(format: .uint3, size: MemoryLayout<SIMD3<UInt32>>.size, alignment: MemoryLayout<SIMD3<UInt32>>.alignment, i: i)
            case is SIMD4<UInt32>:
                offset += writeAttribute(format: .uint4, size: MemoryLayout<SIMD4<UInt32>>.size, alignment: MemoryLayout<SIMD4<UInt32>>.alignment, i: i)
            case is Int32:
                offset += writeAttribute(format: .int, size: MemoryLayout<Int32>.size, alignment: MemoryLayout<Int32>.alignment, i: i)
            case is SIMD2<Int32>:
                offset += writeAttribute(format: .int2, size: MemoryLayout<SIMD2<Int32>>.size, alignment: MemoryLayout<SIMD2<Int32>>.alignment, i: i)
            case is SIMD3<Int32>:
                offset += writeAttribute(format: .int3, size: MemoryLayout<SIMD3<Int32>>.size, alignment: MemoryLayout<SIMD3<Int32>>.alignment, i: i)
            case is SIMD4<Int32>:
                offset += writeAttribute(format: .int4, size: MemoryLayout<SIMD4<Int32>>.size, alignment: MemoryLayout<SIMD4<Int32>>.alignment, i: i)
            default:
                fatalError("Unhandled field type")
            }
        }

        layouts[0].stride = max(offset, MemoryLayout<T>.stride)
        layouts[0].stepRate = 1
        layouts[0].stepFunction = .perVertex

        assert(layouts[0].stride == MemoryLayout<T>.stride, "Your manual walk likely missed padding.")
    }
}

// Used by the reflection init.
func _align(_ value: Int, to alignment: Int) -> Int {
    precondition(alignment > 0 && (alignment & (alignment - 1)) == 0, "alignment must be power of two")
    return (value + alignment - 1) & -alignment
}

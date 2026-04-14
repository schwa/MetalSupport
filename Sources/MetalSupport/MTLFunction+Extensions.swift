import Metal
import simd

public extension MTLFunction {
    /// Infers a vertex descriptor from the function's vertex attributes.
    ///
    /// Each attribute gets its own buffer index. Returns `nil` if the function has no vertex attributes.
    func inferredVertexDescriptor() -> MTLVertexDescriptor? {
        guard let vertexAttributes else {
            return nil
        }
        let vertexDescriptor = MTLVertexDescriptor()
        for attribute in vertexAttributes {
            switch attribute.attributeType {
            case .float:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .float
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Float>.stride

            case .float2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .float2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<Float>>.stride

            case .float3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .float3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Float>.stride * 3

            case .float4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .float4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<Float>>.stride

            case .half:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .half
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt16>.stride

            case .half2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .half2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<UInt16>>.stride

            case .half3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .half3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt16>.stride * 3

            case .half4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .half4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<UInt16>>.stride

            case .int:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .int
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int32>.stride

            case .int2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .int2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<Int32>>.stride

            case .int3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .int3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int32>.stride * 3

            case .int4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .int4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<Int32>>.stride

            case .uint:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uint
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt32>.stride

            case .uint2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uint2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<UInt32>>.stride

            case .uint3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uint3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt32>.stride * 3

            case .uint4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uint4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<UInt32>>.stride

            case .short:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .short
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int16>.stride

            case .short2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .short2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<Int16>>.stride

            case .short3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .short3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int16>.stride * 3

            case .short4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .short4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<Int16>>.stride

            case .ushort:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .ushort
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt16>.stride

            case .ushort2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .ushort2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<UInt16>>.stride

            case .ushort3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .ushort3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt16>.stride * 3

            case .ushort4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .ushort4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<UInt16>>.stride

            case .char:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .char
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int8>.stride

            case .char2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .char2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<Int8>>.stride

            case .char3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .char3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<Int8>.stride * 3

            case .char4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .char4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<Int8>>.stride

            case .uchar:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uchar
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt8>.stride

            case .uchar2:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uchar2
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD2<UInt8>>.stride

            case .uchar3:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uchar3
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<UInt8>.stride * 3

            case .uchar4:
                vertexDescriptor.attributes[attribute.attributeIndex].format = .uchar4
                vertexDescriptor.layouts[attribute.attributeIndex].stride = MemoryLayout<SIMD4<UInt8>>.stride

            default:
                fatalError("Unimplemented: \(attribute.attributeType)")
            }
            vertexDescriptor.attributes[attribute.attributeIndex].bufferIndex = attribute.attributeIndex
        }
        return vertexDescriptor
    }
}

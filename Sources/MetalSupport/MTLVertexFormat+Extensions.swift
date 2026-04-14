import Metal
import ModelIO
import simd

public extension MTLVertexFormat {
    /// Creates a vertex format from the corresponding `MTLDataType`.
    ///
    /// Only `.float2` and `.float3` are currently supported.
    init(_ dataType: MTLDataType) {
        switch dataType {
        case .float3:
            self = .float3

        case .float2:
            self = .float2

        default:
            fatalError("Unimplemented")
        }
    }

    /// Returns the byte size of the vertex format.
    ///
    /// - Parameter packed: When `true`, uses tightly packed size (e.g. 12 bytes for `float3`
    ///   instead of the SIMD-aligned 16 bytes).
    func size(packed: Bool) -> Int {
        switch self {
        case .float3:
            return packed ? MemoryLayout<Float>.stride * 3 : MemoryLayout<SIMD3<Float>>.size

        case .float2:
            return MemoryLayout<SIMD2<Float>>.size

        default:
            fatalError("Unimplemented")
        }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    /// Creates a vertex format from the corresponding `MDLVertexFormat`.
    init(_ dataType: MDLVertexFormat) {
        switch dataType {
        case .invalid:
            self = .invalid

        case .uChar:
            self = .uchar

        case .uChar2:
            self = .uchar2

        case .uChar3:
            self = .uchar3

        case .uChar4:
            self = .uchar4

        case .char:
            self = .char

        case .char2:
            self = .char2

        case .char3:
            self = .char3

        case .char4:
            self = .char4

        case .uCharNormalized:
            self = .ucharNormalized

        case .uChar2Normalized:
            self = .uchar2Normalized

        case .uChar3Normalized:
            self = .uchar3Normalized

        case .uChar4Normalized:
            self = .uchar4Normalized

        case .charNormalized:
            self = .charNormalized

        case .char2Normalized:
            self = .char2Normalized

        case .char3Normalized:
            self = .char3Normalized

        case .char4Normalized:
            self = .char4Normalized

        case .uShort:
            self = .ushort

        case .uShort2:
            self = .ushort2

        case .uShort3:
            self = .ushort3

        case .uShort4:
            self = .ushort4

        case .short:
            self = .short

        case .short2:
            self = .short2

        case .short3:
            self = .short3

        case .short4:
            self = .short4

        case .uShortNormalized:
            self = .ushortNormalized

        case .uShort2Normalized:
            self = .ushort2Normalized

        case .uShort3Normalized:
            self = .ushort3Normalized

        case .uShort4Normalized:
            self = .ushort4Normalized

        case .shortNormalized:
            self = .shortNormalized

        case .short2Normalized:
            self = .short2Normalized

        case .short3Normalized:
            self = .short3Normalized

        case .short4Normalized:
            self = .short4Normalized

        case .uInt:
            self = .uint

        case .uInt2:
            self = .uint2

        case .uInt3:
            self = .uint3

        case .uInt4:
            self = .uint4

        case .int:
            self = .int

        case .int2:
            self = .int2

        case .int3:
            self = .int3

        case .int4:
            self = .int4

        case .half:
            self = .half

        case .half2:
            self = .half2

        case .half3:
            self = .half3

        case .half4:
            self = .half4

        case .float:
            self = .float

        case .float2:
            self = .float2

        case .float3:
            self = .float3

        case .float4:
            self = .float4

        case .int1010102Normalized:
            self = .int1010102Normalized

        case .uInt1010102Normalized:
            self = .uint1010102Normalized

        default:
            fatalError("Unimplemented MDLVertexFormat(\(dataType.rawValue))")
        }
    }
}

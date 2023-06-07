import Metal

extension MTLVertexFormat {

    init?(swiftType string: String) {
        switch string {
        case "SIMD2<Float>":
            self = .float2
        case "SIMD3<Float>":
            self = .float3
        case "SIMD4<Float>":
            self = .float4
        case "Float":
            self = .float
        default:
            return nil
        }
    }

    init?(caseName string: String) {
        switch string {
        case ".invalid": self = .invalid
        case ".uchar2": self = .uchar2
        case ".uchar3": self = .uchar3
        case ".uchar4": self = .uchar4
        case ".char2": self = .char2
        case ".char3": self = .char3
        case ".char4": self = .char4
        case ".uchar2Normalized": self = .uchar2Normalized
        case ".uchar3Normalized": self = .uchar3Normalized
        case ".uchar4Normalized": self = .uchar4Normalized
        case ".char2Normalized": self = .char2Normalized
        case ".char3Normalized": self = .char3Normalized
        case ".char4Normalized": self = .char4Normalized
        case ".ushort2": self = .ushort2
        case ".ushort3": self = .ushort3
        case ".ushort4": self = .ushort4
        case ".short2": self = .short2
        case ".short3": self = .short3
        case ".short4": self = .short4
        case ".ushort2Normalized": self = .ushort2Normalized
        case ".ushort3Normalized": self = .ushort3Normalized
        case ".ushort4Normalized": self = .ushort4Normalized
        case ".short2Normalized": self = .short2Normalized
        case ".short3Normalized": self = .short3Normalized
        case ".short4Normalized": self = .short4Normalized
        case ".half2": self = .half2
        case ".half3": self = .half3
        case ".half4": self = .half4
        case ".float": self = .float
        case ".float2": self = .float2
        case ".float3": self = .float3
        case ".float4": self = .float4
        case ".int": self = .int
        case ".int2": self = .int2
        case ".int3": self = .int3
        case ".int4": self = .int4
        case ".uint": self = .uint
        case ".uint2": self = .uint2
        case ".uint3": self = .uint3
        case ".uint4": self = .uint4
        case ".int1010102Normalized": self = .int1010102Normalized
        case ".uint1010102Normalized": self = .uint1010102Normalized
        case ".uchar4Normalized_bgra": self = .uchar4Normalized_bgra
        case ".uchar": self = .uchar
        case ".char": self = .char
        case ".ucharNormalized": self = .ucharNormalized
        case ".charNormalized": self = .charNormalized
        case ".ushort": self = .ushort
        case ".short": self = .short
        case ".ushortNormalized": self = .ushortNormalized
        case ".shortNormalized": self = .shortNormalized
        case ".half": self = .half
        case ".floatRG11B10": self = .floatRG11B10
        case ".floatRGB9E5": self = .floatRGB9E5
        default:
            return nil
        }
    }

    var caseName: String {
        switch self {
        case .invalid: return ".invalid"
        case .uchar2: return ".uchar2"
        case .uchar3: return ".uchar3"
        case .uchar4: return ".uchar4"
        case .char2: return ".char2"
        case .char3: return ".char3"
        case .char4: return ".char4"
        case .uchar2Normalized: return ".uchar2Normalized"
        case .uchar3Normalized: return ".uchar3Normalized"
        case .uchar4Normalized: return ".uchar4Normalized"
        case .char2Normalized: return ".char2Normalized"
        case .char3Normalized: return ".char3Normalized"
        case .char4Normalized: return ".char4Normalized"
        case .ushort2: return ".ushort2"
        case .ushort3: return ".ushort3"
        case .ushort4: return ".ushort4"
        case .short2: return ".short2"
        case .short3: return ".short3"
        case .short4: return ".short4"
        case .ushort2Normalized: return ".ushort2Normalized"
        case .ushort3Normalized: return ".ushort3Normalized"
        case .ushort4Normalized: return ".ushort4Normalized"
        case .short2Normalized: return ".short2Normalized"
        case .short3Normalized: return ".short3Normalized"
        case .short4Normalized: return ".short4Normalized"
        case .half2: return ".half2"
        case .half3: return ".half3"
        case .half4: return ".half4"
        case .float: return ".float"
        case .float2: return ".float2"
        case .float3: return ".float3"
        case .float4: return ".float4"
        case .int: return ".int"
        case .int2: return ".int2"
        case .int3: return ".int3"
        case .int4: return ".int4"
        case .uint: return ".uint"
        case .uint2: return ".uint2"
        case .uint3: return ".uint3"
        case .uint4: return ".uint4"
        case .int1010102Normalized: return ".int1010102Normalized"
        case .uint1010102Normalized: return ".uint1010102Normalized"
        case .uchar4Normalized_bgra: return ".uchar4Normalized_bgra"
        case .uchar: return ".uchar"
        case .char: return ".char"
        case .ucharNormalized: return ".ucharNormalized"
        case .charNormalized: return ".charNormalized"
        case .ushort: return ".ushort"
        case .short: return ".short"
        case .ushortNormalized: return ".ushortNormalized"
        case .shortNormalized: return ".shortNormalized"
        case .half: return ".half"
        case .floatRG11B10: return ".floatRG11B10"
        case .floatRGB9E5: return ".floatRGB9E5"
        @unknown default:
            fatalError()
        }
    }

    var size: Int {
        switch self {
        case .uchar2:
            return MemoryLayout<UInt8>.stride * 2
        case .uchar3:
            return MemoryLayout<UInt8>.stride * 3
        case .uchar4:
            return MemoryLayout<UInt8>.stride * 4
        case .char2:
            return MemoryLayout<Int8>.stride * 2
        case .char3:
            return MemoryLayout<Int8>.stride * 3
        case .char4:
            return MemoryLayout<Int8>.stride * 4
        case .uchar2Normalized:
            return MemoryLayout<UInt8>.stride * 2
        case .uchar3Normalized:
            return MemoryLayout<UInt8>.stride * 3
        case .uchar4Normalized:
            return MemoryLayout<UInt8>.stride * 4
        case .char2Normalized:
            return MemoryLayout<Int8>.stride * 2
        case .char3Normalized:
            return MemoryLayout<Int8>.stride * 3
        case .char4Normalized:
            return MemoryLayout<Int8>.stride * 4
        case .ushort2:
            return MemoryLayout<UInt16>.stride * 2
        case .ushort3:
            return MemoryLayout<UInt16>.stride * 3
        case .ushort4:
            return MemoryLayout<UInt16>.stride * 4
        case .short2:
            return MemoryLayout<Int16>.stride * 2
        case .short3:
            return MemoryLayout<Int16>.stride * 3
        case .short4:
            return MemoryLayout<Int16>.stride * 4
        case .ushort2Normalized:
            return MemoryLayout<UInt16>.stride * 2
        case .ushort3Normalized:
            return MemoryLayout<UInt16>.stride * 3
        case .ushort4Normalized:
            return MemoryLayout<UInt16>.stride * 4
        case .short2Normalized:
            return MemoryLayout<Int16>.stride * 2
        case .short3Normalized:
            return MemoryLayout<Int16>.stride * 3
        case .short4Normalized:
            return MemoryLayout<Int16>.stride * 4
        case .half2:
            return MemoryLayout<Float16>.stride * 2
        case .half3:
            return MemoryLayout<Float16>.stride * 3
        case .half4:
            return MemoryLayout<Float16>.stride * 4
        case .float:
            return MemoryLayout<Float>.stride
        case .float2:
            return MemoryLayout<Float>.stride * 2
        case .float3:
            return MemoryLayout<Float>.stride * 3
        case .float4:
            return MemoryLayout<Float>.stride * 4
        case .int:
            return MemoryLayout<Int>.stride
        case .int2:
            return MemoryLayout<Int>.stride * 2
        case .int3:
            return MemoryLayout<Int>.stride * 3
        case .int4:
            return MemoryLayout<Int>.stride * 4
        case .uint:
            return MemoryLayout<UInt>.stride
        case .uint2:
            return MemoryLayout<UInt>.stride * 2
        case .uint3:
            return MemoryLayout<UInt>.stride * 3
        case .uint4:
            return MemoryLayout<UInt>.stride * 4
        case .int1010102Normalized:
            return 4
        case .uint1010102Normalized:
            return 4
        case .uchar4Normalized_bgra:
            return MemoryLayout<UInt8>.stride * 4
        case .uchar:
            return MemoryLayout<UInt8>.stride
        case .char:
            return MemoryLayout<Int8>.stride
        case .ucharNormalized:
            return MemoryLayout<UInt8>.stride
        case .charNormalized:
            return MemoryLayout<Int8>.stride
        case .ushort:
            return MemoryLayout<UInt16>.stride
        case .short:
            return MemoryLayout<Int16>.stride
        case .ushortNormalized:
            return MemoryLayout<UInt16>.stride
        case .shortNormalized:
            return MemoryLayout<Int16>.stride
        case .half:
            return MemoryLayout<Float16>.stride
        case .floatRG11B10:
            return 4
        case .floatRGB9E5:
            return 4
        case .invalid:
            fatalError()
        @unknown default:
            fatalError()
        }
    }
}

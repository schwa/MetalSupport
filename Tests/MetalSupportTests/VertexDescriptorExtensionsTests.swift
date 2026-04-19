import Metal
import MetalKit
@testable import MetalSupport
import ModelIO
import Testing

@Suite("MTLVertexDescriptor(vertexAttributes:)")
struct VertexDescriptorFromAttributesTests {
    let device: MTLDevice

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
    }

    /// Build a tiny shader library with a known vertex signature so we can
    /// pull real `MTLVertexAttribute` values out of `MTLFunction`.
    private func makeVertexFunction(source: String) throws -> MTLFunction {
        let library = try device.makeLibrary(source: source, options: nil)
        guard let function = library.makeFunction(name: "vert_main") else {
            throw MetalSupportError.resourceCreationFailure("vert_main not found")
        }
        return function
    }

    @Test func inferredVertexDescriptorFloatAndInt() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            float3 pos [[attribute(0)]];
            float2 uv [[attribute(1)]];
            int id [[attribute(2)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) {
            return float4(v.pos, 1);
        }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor != nil)
        #expect(descriptor?.attributes[0].format == .float3)
        #expect(descriptor?.attributes[1].format == .float2)
        #expect(descriptor?.attributes[2].format == .int)
        #expect(descriptor?.attributes[0].bufferIndex == 0)
        #expect(descriptor?.attributes[1].bufferIndex == 1)
        #expect(descriptor?.attributes[2].bufferIndex == 2)
    }

    @Test func inferredVertexDescriptorFloatFamily() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            float f [[attribute(0)]];
            float2 f2 [[attribute(1)]];
            float3 f3 [[attribute(2)]];
            float4 f4 [[attribute(3)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(0); }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor?.attributes[0].format == .float)
        #expect(descriptor?.attributes[1].format == .float2)
        #expect(descriptor?.attributes[2].format == .float3)
        #expect(descriptor?.attributes[3].format == .float4)
    }

    @Test func inferredVertexDescriptorHalfFamily() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            half h [[attribute(0)]];
            half2 h2 [[attribute(1)]];
            half3 h3 [[attribute(2)]];
            half4 h4 [[attribute(3)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(0); }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor?.attributes[0].format == .half)
        #expect(descriptor?.attributes[1].format == .half2)
        #expect(descriptor?.attributes[2].format == .half3)
        #expect(descriptor?.attributes[3].format == .half4)
    }

    @Test func inferredVertexDescriptorIntFamily() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            int i [[attribute(0)]];
            int2 i2 [[attribute(1)]];
            int3 i3 [[attribute(2)]];
            int4 i4 [[attribute(3)]];
            uint u [[attribute(4)]];
            uint2 u2 [[attribute(5)]];
            uint3 u3 [[attribute(6)]];
            uint4 u4 [[attribute(7)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(0); }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor?.attributes[0].format == .int)
        #expect(descriptor?.attributes[1].format == .int2)
        #expect(descriptor?.attributes[2].format == .int3)
        #expect(descriptor?.attributes[3].format == .int4)
        #expect(descriptor?.attributes[4].format == .uint)
        #expect(descriptor?.attributes[5].format == .uint2)
        #expect(descriptor?.attributes[6].format == .uint3)
        #expect(descriptor?.attributes[7].format == .uint4)
    }

    @Test func inferredVertexDescriptorShortFamily() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            short s [[attribute(0)]];
            short2 s2 [[attribute(1)]];
            short3 s3 [[attribute(2)]];
            short4 s4 [[attribute(3)]];
            ushort u [[attribute(4)]];
            ushort2 u2 [[attribute(5)]];
            ushort3 u3 [[attribute(6)]];
            ushort4 u4 [[attribute(7)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(0); }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor?.attributes[0].format == .short)
        #expect(descriptor?.attributes[1].format == .short2)
        #expect(descriptor?.attributes[2].format == .short3)
        #expect(descriptor?.attributes[3].format == .short4)
        #expect(descriptor?.attributes[4].format == .ushort)
        #expect(descriptor?.attributes[5].format == .ushort2)
        #expect(descriptor?.attributes[6].format == .ushort3)
        #expect(descriptor?.attributes[7].format == .ushort4)
    }

    @Test func inferredVertexDescriptorCharFamily() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            char c [[attribute(0)]];
            char2 c2 [[attribute(1)]];
            char3 c3 [[attribute(2)]];
            char4 c4 [[attribute(3)]];
            uchar u [[attribute(4)]];
            uchar2 u2 [[attribute(5)]];
            uchar3 u3 [[attribute(6)]];
            uchar4 u4 [[attribute(7)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(0); }
        """
        let function = try makeVertexFunction(source: source)
        let descriptor = function.inferredVertexDescriptor()
        #expect(descriptor?.attributes[0].format == .char)
        #expect(descriptor?.attributes[1].format == .char2)
        #expect(descriptor?.attributes[2].format == .char3)
        #expect(descriptor?.attributes[3].format == .char4)
        #expect(descriptor?.attributes[4].format == .uchar)
        #expect(descriptor?.attributes[5].format == .uchar2)
        #expect(descriptor?.attributes[6].format == .uchar3)
        #expect(descriptor?.attributes[7].format == .uchar4)
    }

    // NOTE: MTLVertexDescriptor(reflection:) crashes under -O0 tests on arm64e
    // because Mirror over memory-rebound zeroed bytes trips a runtime check.
    // Not covered here; see source-level note in MetalSupportTests.swift.

    @Test func alignHelper() {
        #expect(_align(0, to: 4) == 0)
        #expect(_align(1, to: 4) == 4)
        #expect(_align(5, to: 4) == 8)
        #expect(_align(16, to: 16) == 16)
        #expect(_align(17, to: 16) == 32)
    }

    @Test func vertexDescriptorFromVertexAttributesList() throws {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn {
            float3 pos [[attribute(0)]];
            float2 uv [[attribute(1)]];
        };
        vertex float4 vert_main(VIn v [[stage_in]]) {
            return float4(v.pos, 1);
        }
        """
        let function = try makeVertexFunction(source: source)
        guard let attributes = function.vertexAttributes else {
            throw MetalSupportError.resourceCreationFailure("No vertex attributes on function")
        }
        let descriptor = MTLVertexDescriptor(vertexAttributes: attributes)
        #expect(descriptor.attributes[0].format == .float3)
        #expect(descriptor.attributes[0].offset == 0)
        #expect(descriptor.attributes[1].format == .float2)
        #expect(descriptor.attributes[1].offset == 12) // packed float3
        #expect(descriptor.layouts[0].stride == 20)
    }
}

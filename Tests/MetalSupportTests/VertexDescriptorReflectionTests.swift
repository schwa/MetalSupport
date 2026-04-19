import Metal
@testable import MetalSupport
import simd
import Testing

// Isolated tests for MTLVertexDescriptor(reflection:).
//
// The reflection init uses `withMemoryRebound` on zeroed bytes and then takes a
// `Mirror`. Certain types (notably scalar integer types and some SIMD integer
// types) trip a Swift stdlib fatal error on arm64e macOS when reflecting over
// zeroed storage. Only the format families that survive that pass are covered
// here.
@Suite("VertexDescriptor reflection init")
struct VertexDescriptorReflectionTests {
    @Test func floatOnlyStruct() {
        struct Vertex {
            var a: Float
            var b: SIMD2<Float>
        }
        let vd = MTLVertexDescriptor(reflection: Vertex.self)
        #expect(vd.attributes[0].format == .float)
        #expect(vd.attributes[1].format == .float2)
        #expect(vd.layouts[0].stride == MemoryLayout<Vertex>.stride)
    }

    @Test func simd3AndSimd4Float() {
        struct Vertex {
            var pos: SIMD3<Float>
            var col: SIMD4<Float>
        }
        let vd = MTLVertexDescriptor(reflection: Vertex.self)
        #expect(vd.attributes[0].format == .float3)
        #expect(vd.attributes[1].format == .float4)
        #expect(vd.layouts[0].stride == MemoryLayout<Vertex>.stride)
    }
}

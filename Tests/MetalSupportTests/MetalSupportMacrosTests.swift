import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MetalSupport
import MetalSupportMacros

let testMacros: [String: Macro.Type] = [
    "VertexDescriptor": VertexDescriptorMacro.self
]

final class VertexDescriptorMacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @VertexDescriptor
            struct MyVertex {
                var position: SIMD3<Float>
                var color: SIMD4<Float>
            }
            """,
            expandedSource: """

            struct MyVertex {
                var position: SIMD3<Float>
                var color: SIMD4<Float>
                static var _vertexDescriptor: MTLVertexDescriptor {
                    let descriptor = MTLVertexDescriptor()
                    // Attribute for ``position``: ``SIMD3<Float>``
                    attributes[0].format = .float3
                    attributes[0].offset = -1
                    attributes[0].bufferIndex = 0
                    // Attribute for ``color``: ``SIMD4<Float>``
                    attributes[1].format = .float4
                    attributes[1].offset = -1
                    attributes[1].bufferIndex = 0
                    descriptor.layouts[0].stride = -1
                    return descriptor
                }
            }
            """,
            macros: testMacros
        )
    }
}

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MetalSupport
import MetalSupportMacros

let testMacros: [String: Macro.Type] = [
    "VertexDescriptor": VertexDescriptorMacro.self,
    "VertexAttribute": VertexDescriptorMacro.self,
]

final class VertexDescriptorMacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @VertexDescriptor
            struct MyVertex {
                @VertexAttribute(.float3)
                var position: SIMD3<Float>
                @VertexAttribute
                var ambient: SIMD4<Float>
                @VertexAttribute(.float4, bufferIndex: 1)
                var specular: SIMD4<Float>
                @VertexAttribute(bufferIndex: 1)
                var specular: SIMD4<Float>
            }
            """,
            expandedSource: """
            """,
            macros: testMacros
        )
    }
}

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

    func testMacroNoAttributes() {
        assertMacroExpansion(
            """
            @VertexDescriptor
            struct MyVertex {
            }
            """,
            expandedSource: """

            struct MyVertex {
                static var vertexDescriptor: MTLVertexDescriptor {
                    let d = MTLVertexDescriptor()
                    return d
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroBareAttributes() {
        assertMacroExpansion(
            """
            @VertexDescriptor
            struct MyVertex {
                var color: SIMD4<Float>
            }
            """,
            expandedSource: """

            struct MyVertex {
                var color: SIMD4<Float>
                static var vertexDescriptor: MTLVertexDescriptor {
                    let d = MTLVertexDescriptor()
                // Attribute for ``color``: ``SIMD4<Float>``
                d.attributes[0].format = .float4
                d.attributes[0].offset = 0
                d.attributes[0].bufferIndex = 0
                d.layouts[0].stride = 16
                return d
                }
            }
            """,
            macros: testMacros
        )
    }

//    func testMacro() {
//        assertMacroExpansion(
//            """
//            @VertexDescriptor
//            struct MyVertex {
//                // Don't specify anything - let macro infer
//                var position: SIMD3<Float>
//
//                // Tell the macro what the attribute type is if it can't infer
//                @VertexAttribute(.float4)
//                var ambient: (Float, Float, Float, Float)
//
//                // Specify the buffer index explicitely (otherwise 0 is assumed)
//                @VertexAttribute(bufferIndex: 1)
//                var specular: SIMD4<Float>
//
//                // Specify both format and buffer index. Note there is a mismatch here and the macro system _should_ catch it (note currently does not)
//                @VertexAttribute(.float4, bufferIndex: 1)
//                var texture: SIMD2<Float>
//            }
//            """,
//            expandedSource: """
//            """,
//            macros: testMacros
//        )
//    }
}

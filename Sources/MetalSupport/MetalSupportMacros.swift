import Metal

@attached(member, names: named(vertexDescriptor))
public macro VertexDescriptor() = #externalMacro(module: "MetalSupportMacros", type: "VertexDescriptorMacro")

@attached(member)
public macro VertexAttribute(_ format: MTLVertexFormat? = nil, bufferIndex: Int = 0) = #externalMacro(module: "MetalSupportMacros", type: "VertexAttributeMacro")

@freestanding(expression)
public macro VertexBufferLayout(index: Int, stride: UInt? = nil, stepFunction: MTLVertexStepFunction? = nil, stepRate: UInt? = nil) = #externalMacro(module: "MetalSupportMacros", type: "VertexBufferLayoutMacro")

public protocol VertexDescriptorProviding {
    var vertexDescriptor: MTLVertexDescriptor { get }
}

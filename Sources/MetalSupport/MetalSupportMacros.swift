import Metal

@attached(member, names: named(_vertexDescriptor))
public macro VertexDescriptor() = #externalMacro(module: "MetalSupportMacros", type: "VertexDescriptorMacro")

@attached(member)
public macro VertexAttribute(_ format: MTLVertexFormat? = nil, bufferIndex: Int = 0) = #externalMacro(module: "MetalSupportMacros", type: "VertexAttributeMacro")

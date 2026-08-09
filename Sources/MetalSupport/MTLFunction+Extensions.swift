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
            let format = MTLVertexFormat(attribute.attributeType)
            vertexDescriptor.attributes[attribute.attributeIndex].format = format
            vertexDescriptor.attributes[attribute.attributeIndex].bufferIndex = attribute.attributeIndex
            vertexDescriptor.layouts[attribute.attributeIndex].stride = format.size
        }
        return vertexDescriptor
    }
}

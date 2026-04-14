import Metal
import MetalKit

public extension MTLRenderCommandEncoder {
    /// Binds all vertex buffers from the mesh.
    func setVertexBuffers(of mesh: MTKMesh) {
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: index)
        }
    }

    /// Issues indexed draw calls for every submesh of the mesh.
    func draw(_ mesh: MTKMesh) {
        for submesh in mesh.submeshes {
            draw(submesh)
        }
    }

    /// Issues an indexed draw call for a single submesh.
    func draw(_ submesh: MTKSubmesh) {
        drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }

    /// Issues instanced indexed draw calls for every submesh.
    func draw(_ mesh: MTKMesh, instanceCount: Int) {
        for submesh in mesh.submeshes {
            draw(submesh, instanceCount: instanceCount)
        }
    }

    /// Issues an instanced indexed draw call for a single submesh.
    func draw(_ submesh: MTKSubmesh, instanceCount: Int) {
        drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset, instanceCount: instanceCount)
    }
}

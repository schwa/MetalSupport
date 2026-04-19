import Metal
import MetalKit
@testable import MetalSupport
import Testing

@Suite("DrawHelpers + Labeled")
struct DrawHelpersAndLabeledTests {
    let device: MTLDevice
    let queue: MTLCommandQueue

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
        self.queue = try device._makeCommandQueue()
    }

    private func makeRenderEncoder(commandBuffer: MTLCommandBuffer) throws -> (MTLRenderCommandEncoder, MTLTexture) {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        desc.usage = [.renderTarget]
        desc.storageMode = .private
        let texture = try device._makeTexture(descriptor: desc)
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        let encoder = try commandBuffer._makeRenderCommandEncoder(descriptor: pass)
        return (encoder, texture)
    }

    // MARK: - DrawHelpers

    @Test func setVertexBuffers() throws {
        let cb = try queue._makeCommandBuffer()
        let (encoder, _) = try makeRenderEncoder(commandBuffer: cb)
        defer { encoder.endEncoding() }
        let mesh = MTKMesh.box()
        encoder.setVertexBuffers(of: mesh)
    }

    /// Builds a minimal render pipeline that accepts an MTKMesh's default vertex descriptor.
    private func makePipeline(for mesh: MTKMesh) throws -> MTLRenderPipelineState {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct VIn { float3 pos [[attribute(0)]]; };
        vertex float4 vert_main(VIn v [[stage_in]]) { return float4(v.pos, 1); }
        fragment float4 frag_main() { return float4(1); }
        """
        let library = try device.makeLibrary(source: source, options: nil)
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = library.makeFunction(name: "vert_main")
        pipelineDesc.fragmentFunction = library.makeFunction(name: "frag_main")
        pipelineDesc.colorAttachments[0].pixelFormat = .rgba8Unorm
        let mtlVD = MTLVertexDescriptor()
        mtlVD.attributes[0].format = .float3
        mtlVD.attributes[0].offset = 0
        mtlVD.attributes[0].bufferIndex = 0
        let layout = mesh.vertexDescriptor.layouts[0] as? MDLVertexBufferLayout
        mtlVD.layouts[0].stride = layout?.stride ?? MemoryLayout<SIMD3<Float>>.stride
        pipelineDesc.vertexDescriptor = mtlVD
        return try device.makeRenderPipelineState(descriptor: pipelineDesc)
    }

    @Test func drawMeshAndSubmesh() throws {
        let cb = try queue._makeCommandBuffer()
        let (encoder, _) = try makeRenderEncoder(commandBuffer: cb)
        let mesh = MTKMesh.box()
        let pipeline = try makePipeline(for: mesh)
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffers(of: mesh)
        encoder.draw(mesh)
        // Exercise the single-submesh overload too
        if let submesh = mesh.submeshes.first {
            encoder.draw(submesh)
        }
        encoder.endEncoding()
        cb.commit()
        cb.waitUntilCompleted()
    }

    @Test func drawMeshInstanced() throws {
        let cb = try queue._makeCommandBuffer()
        let (encoder, _) = try makeRenderEncoder(commandBuffer: cb)
        let mesh = MTKMesh.box()
        let pipeline = try makePipeline(for: mesh)
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffers(of: mesh)
        encoder.draw(mesh, instanceCount: 2)
        if let submesh = mesh.submeshes.first {
            encoder.draw(submesh, instanceCount: 3)
        }
        encoder.endEncoding()
        cb.commit()
        cb.waitUntilCompleted()
    }

    @Test func drawSubmeshAndInstancedSignatures() {
        // We can't actually issue draws without a pipeline bound, but we can
        // construct the call sites by wrapping in pushDebugGroup/pop.
        // This test just verifies the mesh/submesh scaffolding runs.
        let mesh = MTKMesh.box()
        #expect(!mesh.submeshes.isEmpty)
        for submesh in mesh.submeshes {
            #expect(submesh.indexCount > 0)
        }
    }

    // MARK: - Labeled

    @Test func commandQueueLabeled() {
        let labeled = queue.labeled("myQueue")
        #expect(labeled.label == "myQueue")
    }

    @Test func commandBufferLabeled() throws {
        let cb = try queue._makeCommandBuffer().labeled("myCB")
        #expect(cb.label == "myCB")
    }

    @Test func renderCommandEncoderLabeled() throws {
        let cb = try queue._makeCommandBuffer()
        let (encoder, _) = try makeRenderEncoder(commandBuffer: cb)
        let labeled = encoder.labeled("myEncoder")
        #expect(labeled.label == "myEncoder")
        encoder.endEncoding()
    }

    @Test func textureLabeled() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 2, height: 2, mipmapped: false)
        desc.storageMode = .shared
        let texture = try device._makeTexture(descriptor: desc).labeled("myTexture")
        #expect(texture.label == "myTexture")
    }
}

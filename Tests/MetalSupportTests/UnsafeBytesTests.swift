import Metal
import MetalKit
@testable import MetalSupport
import Testing

@Suite("UnsafeBytes")
struct UnsafeBytesTests {
    let device: MTLDevice
    let queue: MTLCommandQueue
    let commandBuffer: MTLCommandBuffer

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
        self.queue = try device._makeCommandQueue()
        self.commandBuffer = try queue._makeCommandBuffer()
    }

    // MARK: - Compute encoder

    @Test func computeSetBytesValue() throws {
        let encoder = try commandBuffer._makeComputeCommandEncoder()
        defer { encoder.endEncoding() }
        let value = SIMD4<Float>(1, 2, 3, 4)
        encoder.setUnsafeBytes(of: value, index: 0)
    }

    @Test func computeSetBytesArray() throws {
        let encoder = try commandBuffer._makeComputeCommandEncoder()
        defer { encoder.endEncoding() }
        let values: [Float] = [1, 2, 3, 4]
        encoder.setUnsafeBytes(of: values, index: 0)
    }

    // MARK: - Render encoder (requires a render target)

    private func makeRenderEncoder() throws -> MTLRenderCommandEncoder {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        desc.usage = [.renderTarget]
        desc.storageMode = .private
        let texture = try device._makeTexture(descriptor: desc)

        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store

        return try commandBuffer._makeRenderCommandEncoder(descriptor: pass)
    }

    @Test func renderSetVertexBytesArray() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let values: [Float] = [1, 2, 3]
        encoder.setVertexUnsafeBytes(of: values, index: 0)
    }

    @Test func renderSetVertexBytesValue() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let value = SIMD2<Float>(1, 2)
        encoder.setVertexUnsafeBytes(of: value, index: 0)
    }

    @Test func renderSetFragmentBytesArray() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let values: [Float] = [1]
        encoder.setFragmentUnsafeBytes(of: values, index: 0)
    }

    @Test func renderSetFragmentBytesValue() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let value = Float(3.14)
        encoder.setFragmentUnsafeBytes(of: value, index: 0)
    }

    @Test func renderSetUnsafeBytesVertexAndFragmentByFunctionType() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let value = SIMD4<Float>(1, 2, 3, 4)
        encoder.setUnsafeBytes(of: value, index: 0, functionType: .vertex)
        encoder.setUnsafeBytes(of: value, index: 1, functionType: .fragment)
        let values: [Float] = [1, 2]
        encoder.setUnsafeBytes(of: values, index: 2, functionType: .vertex)
        encoder.setUnsafeBytes(of: values, index: 3, functionType: .fragment)
    }

    @Test func renderSetBufferByFunctionType() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let buffer = try device.makeBuffer(unsafeBytesOf: [Float]([1, 2, 3, 4]))
        encoder.setBuffer(buffer, offset: 0, index: 0, functionType: .vertex)
        encoder.setBuffer(buffer, offset: 0, index: 1, functionType: .fragment)
    }

    @Test func renderSetTextureByFunctionType() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let texture = try device.make1PixelTexture(color: [1, 1, 1, 1])
        encoder.setTexture(texture, index: 0, functionType: .vertex)
        encoder.setTexture(texture, index: 1, functionType: .fragment)
    }

    @Test func renderSetSamplerStateByFunctionType() throws {
        let encoder = try makeRenderEncoder()
        defer { encoder.endEncoding() }
        let sampler = try device._makeSamplerState(descriptor: MTLSamplerDescriptor())
        encoder.setSamplerState(sampler, index: 0, functionType: .vertex)
        encoder.setSamplerState(sampler, index: 1, functionType: .fragment)
    }

    // MARK: - Argument encoder

    @Test func argumentEncoderSetBytes() throws {
        let argDesc = MTLArgumentDescriptor(dataType: .float4, index: 0, access: .readOnly)
        guard let encoder = device.makeArgumentEncoder(arguments: [argDesc]) else {
            return
        }
        let buffer = try device.makeBuffer(length: encoder.encodedLength, options: .storageModeShared).orThrow(.resourceCreationFailure("buffer"))
        encoder.setArgumentBuffer(buffer, offset: 0)
        let value = SIMD4<Float>(1, 2, 3, 4)
        encoder.setBytes(of: value, index: 0)
    }

    // MARK: - Object / Mesh stages (mesh pipeline)

    private func makeMeshPipeline() throws -> MTLRenderPipelineState? {
        // Need Apple7+ for mesh shaders.
        guard device.supportsFamily(.apple7) || device.supportsFamily(.apple8) || device.supportsFamily(.apple9) else {
            return nil
        }
        // swiftlint:disable indentation_width
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct Payload { float dummy; };
        struct VOut { float4 position [[position]]; };
        using Mesh = metal::mesh<VOut, void, 3, 1, metal::topology::triangle>;
        [[object]] void obj_main(object_data Payload& payload [[payload]],
                                 mesh_grid_properties mgp) {
            payload.dummy = 1.0;
            mgp.set_threadgroups_per_grid(uint3(1, 1, 1));
        }
        [[mesh]] void mesh_main(Mesh out, const object_data Payload& payload [[payload]]) {
            out.set_primitive_count(0);
        }
        fragment float4 frag_main() { return float4(1); }
        """
        // swiftlint:enable indentation_width
        let library = try device.makeLibrary(source: source, options: nil)
        let desc = MTLMeshRenderPipelineDescriptor()
        desc.objectFunction = library.makeFunction(name: "obj_main")
        desc.meshFunction = library.makeFunction(name: "mesh_main")
        desc.fragmentFunction = library.makeFunction(name: "frag_main")
        desc.colorAttachments[0].pixelFormat = .rgba8Unorm
        return try device.makeRenderPipelineState(descriptor: desc, options: []).0
    }

    @Test func renderSetObjectAndMeshBytes() throws {
        guard let pipeline = try makeMeshPipeline() else {
            return
        }
        let encoder = try makeRenderEncoder()
        encoder.setRenderPipelineState(pipeline)
        let value = SIMD4<Float>(1, 2, 3, 4)
        let values: [Float] = [1, 2, 3]
        encoder.setObjectUnsafeBytes(of: value, index: 0)
        encoder.setObjectUnsafeBytes(of: values, index: 1)
        encoder.setMeshUnsafeBytes(of: value, index: 0)
        encoder.setMeshUnsafeBytes(of: values, index: 1)
        // Also exercise the function-type dispatch helpers
        encoder.setUnsafeBytes(of: value, index: 2, functionType: .object)
        encoder.setUnsafeBytes(of: value, index: 3, functionType: .mesh)
        encoder.setUnsafeBytes(of: values, index: 4, functionType: .object)
        encoder.setUnsafeBytes(of: values, index: 5, functionType: .mesh)
        // And setBuffer / setTexture / setSamplerState for object+mesh
        let buffer = try device.makeBuffer(unsafeBytesOf: Float(1))
        encoder.setBuffer(buffer, offset: 0, index: 6, functionType: .object)
        encoder.setBuffer(buffer, offset: 0, index: 7, functionType: .mesh)
        let texture = try device.make1PixelTexture(color: [1, 1, 1, 1])
        encoder.setTexture(texture, index: 0, functionType: .object)
        encoder.setTexture(texture, index: 1, functionType: .mesh)
        let sampler = try device._makeSamplerState(descriptor: MTLSamplerDescriptor())
        encoder.setSamplerState(sampler, index: 0, functionType: .object)
        encoder.setSamplerState(sampler, index: 1, functionType: .mesh)
        encoder.endEncoding()
    }
}

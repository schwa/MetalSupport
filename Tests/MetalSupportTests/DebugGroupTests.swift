import Metal
@testable import MetalSupport
import Testing

@Suite("DebugGroup")
struct DebugGroupTests {
    let device: MTLDevice
    let queue: MTLCommandQueue

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
        self.queue = try device._makeCommandQueue()
    }

    @Test func commandBufferWithDebugGroup() throws {
        let cb = try queue._makeCommandBuffer()
        let result = cb.withDebugGroup("test") { 42 }
        #expect(result == 42)
    }

    @Test func commandBufferWithDebugGroupDisabled() throws {
        let cb = try queue._makeCommandBuffer()
        let result = cb.withDebugGroup(enabled: false, "test") { "hello" }
        #expect(result == "hello")
    }

    @Test func renderCommandEncoderWithDebugGroup() throws {
        let cb = try queue._makeCommandBuffer()
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        desc.usage = [.renderTarget]
        desc.storageMode = .private
        let texture = try device._makeTexture(descriptor: desc)
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        let encoder = try cb._makeRenderCommandEncoder(descriptor: pass)
        let result = encoder.withDebugGroup("test") { 7 }
        #expect(result == 7)
        let disabledResult = encoder.withDebugGroup(enabled: false, "skipped") { 9 }
        #expect(disabledResult == 9)
        encoder.endEncoding()
    }

    @Test func computeCommandEncoderWithDebugGroup() throws {
        let cb = try queue._makeCommandBuffer()
        let encoder = try cb._makeComputeCommandEncoder()
        let result = encoder.withDebugGroup("compute") { 1 }
        #expect(result == 1)
        let disabled = encoder.withDebugGroup(enabled: false, "nope") { 2 }
        #expect(disabled == 2)
        encoder.endEncoding()
    }

    @Test func blitCommandEncoderWithDebugGroup() throws {
        let cb = try queue._makeCommandBuffer()
        let encoder = try cb._makeBlitCommandEncoder()
        let result = encoder.withDebugGroup(label: "blit") { 5 }
        #expect(result == 5)
        let disabled = encoder.withDebugGroup(enabled: false, label: "nope") { 10 }
        #expect(disabled == 10)
        encoder.endEncoding()
    }

    @Test func captureManagerWithDisabled() throws {
        // Only exercise the disabled branch, since starting a capture without
        // MTL_CAPTURE_ENABLED set will throw.
        let result = try MTLCaptureManager.shared().with(enabled: false) { 99 }
        #expect(result == 99)
    }
}

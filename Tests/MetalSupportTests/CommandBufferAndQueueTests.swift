import Metal
@testable import MetalSupport
import Testing

@Suite("MTLCommandQueue + MTLCommandBuffer extensions")
struct CommandBufferAndQueueTests {
    let device: MTLDevice
    let queue: MTLCommandQueue

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
        self.queue = try device._makeCommandQueue()
    }

    // MARK: - Queue extensions

    @Test func makeCommandBuffer() throws {
        let cb = try queue._makeCommandBuffer()
        #expect(cb.commandQueue === queue)
    }

    @Test func makeCommandBufferFromDescriptor() throws {
        let desc = MTLCommandBufferDescriptor()
        let cb = try queue._makeCommandBuffer(descriptor: desc)
        #expect(cb.commandQueue === queue)
    }

    @Test func withCommandBufferNoWait() {
        var called = false
        queue.withCommandBuffer(waitAfterCommit: false) { cb in
            called = true
            #expect(cb.commandQueue === queue)
        }
        #expect(called)
    }

    @Test func withCommandBufferWait() {
        var called = false
        queue.withCommandBuffer(waitAfterCommit: true) { cb in
            called = true
            _ = cb
        }
        #expect(called)
    }

    @Test func withCommandBufferDrawableNil() {
        var called = false
        queue.withCommandBuffer(drawable: nil) { cb in
            called = true
            _ = cb
        }
        #expect(called)
    }

    // MARK: - Command buffer extensions

    @Test func makeBlitCommandEncoder() throws {
        let cb = try queue._makeCommandBuffer()
        let encoder = try cb._makeBlitCommandEncoder()
        encoder.endEncoding()
    }

    @Test func makeComputeCommandEncoder() throws {
        let cb = try queue._makeCommandBuffer()
        let encoder = try cb._makeComputeCommandEncoder()
        encoder.endEncoding()
    }

    @Test func makeRenderCommandEncoder() throws {
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
        encoder.endEncoding()
    }

    @Test func withRenderCommandEncoder() throws {
        let cb = try queue._makeCommandBuffer()
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        desc.usage = [.renderTarget]
        desc.storageMode = .private
        let texture = try device._makeTexture(descriptor: desc)
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        var called = false
        let result = cb.withRenderCommandEncoder(descriptor: pass) { encoder in
            called = true
            _ = encoder
            return 42
        }
        #expect(called)
        #expect(result == 42)
    }

    // MARK: - Command buffer descriptor

    @Test func commandBufferDescriptorDefaultLogging() throws {
        let desc = MTLCommandBufferDescriptor()
        try desc.addDefaultLogging()
        #expect(desc.logState != nil)
    }
}

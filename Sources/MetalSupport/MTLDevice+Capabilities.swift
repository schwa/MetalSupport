import Metal

// Runtime GPU capability checks for gating tests on hardware features. Kept free of the Testing framework so apps can
// link MetalSupport; each test target wraps these in its own traits.

public extension MTLDevice {
    /// True for the paravirtualized GPU in macOS VMs, including GitHub Actions runners.
    var isParavirtual: Bool {
        name.localizedCaseInsensitiveContains("paravirtual")
    }

    /// True when the device supports Metal 4 (`MTLGPUFamily.metal4`).
    var supportsMetal4: Bool {
        if #available(macOS 26, iOS 26, tvOS 26, visionOS 26, *) {
            return supportsFamily(.metal4)
        }
        return false
    }

    /// True when the device can encode mesh-shader draws.
    ///
    /// Paravirtual GPUs advertise Metal 3 but their render encoders lack the mesh-stage selectors, so binding a mesh
    /// buffer raises an Objective-C exception. A debug or validation layer wraps the encoder and answers
    /// `responds(to:)` for every selector, so paravirtual devices are excluded by name before probing.
    var supportsMeshShaders: Bool {
        guard !isParavirtual, let commandQueue = makeCommandQueue() else {
            return false
        }
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1, height: 1, mipmapped: false)
        textureDescriptor.usage = [.renderTarget]
        textureDescriptor.storageMode = .private
        guard let texture = makeTexture(descriptor: textureDescriptor) else {
            return false
        }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .dontCare
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return false
        }
        let responds = (encoder as AnyObject).responds(to: NSSelectorFromString("setMeshBuffer:offset:atIndex:"))
        encoder.endEncoding()
        return responds
    }
}

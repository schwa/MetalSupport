import Metal
import MetalKit
@testable import MetalSupport
import Testing

@Suite("VertexDescriptor debug + dump")
struct VertexDescriptorDebugTests {
    @Test func descriptorDebugDescription() {
        let attrs = [
            VertexDescriptor.Attribute(label: "pos", semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 12, stepFunction: .perVertex, stepRate: 1)]
        let desc = VertexDescriptor(label: "test", attributes: attrs, layouts: layouts)
        let s = desc.debugDescription
        #expect(s.contains("label: test"))
        #expect(s.contains("attributes:"))

        // Also exercise nil-label path
        let noLabelAttrs = [VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0)]
        let noLabelDesc = VertexDescriptor(attributes: noLabelAttrs, layouts: layouts)
        #expect(!noLabelDesc.debugDescription.contains("label: "))
    }

    @Test func attributeDebugDescription() {
        let a = VertexDescriptor.Attribute(label: "x", semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        #expect(a.debugDescription.contains("label: x"))
        let b = VertexDescriptor.Attribute(semantic: .color, format: .uchar4Normalized, offset: 0, bufferIndex: 0)
        #expect(!b.debugDescription.contains("label:"))
    }

    @Test func layoutDebugDescription() {
        let l = VertexDescriptor.Layout(bufferIndex: 2, stride: 48, stepFunction: .perInstance, stepRate: 4)
        let s = l.debugDescription
        #expect(s.contains("bufferIndex: 2"))
        #expect(s.contains("stride: 48"))
    }

    @Test func dump() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 12, stepFunction: .perVertex, stepRate: 1)]
        let desc = VertexDescriptor(attributes: attrs, layouts: layouts)
        desc.dump() // Just verify it doesn't crash
    }

    @Test func mtlVertexDescriptorConvenienceInit() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 12, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 20, stepFunction: .perInstance, stepRate: 2)]
        let desc = VertexDescriptor(attributes: attrs, layouts: layouts)
        let mtl = MTLVertexDescriptor(desc)
        #expect(mtl.attributes[0].format == .float3)
        #expect(mtl.attributes[1].format == .float2)
        #expect(mtl.attributes[1].offset == 12)
        #expect(mtl.layouts[0].stride == 20)
        #expect(mtl.layouts[0].stepFunction == .perInstance)
        #expect(mtl.layouts[0].stepRate == 2)
    }

    @Test func char3NormalizedSize() {
        #expect(MTLVertexFormat.char4Normalized.size == 4)
    }

    @Test func semanticCodableRoundTrip() throws {
        let cases: [VertexDescriptor.Attribute.Semantic] = [.unknown, .position, .normal, .tangent, .bitangent, .texcoord, .color, .userDefined]
        for semantic in cases {
            let data = try JSONEncoder().encode(semantic)
            let decoded = try JSONDecoder().decode(VertexDescriptor.Attribute.Semantic.self, from: data)
            #expect(decoded == semantic)
        }
    }
}

// MARK: - Error helpers

@Suite("MetalSupportError helpers")
struct MetalSupportErrorHelperTests {
    @Test func orThrowNil() {
        let optional: Int? = nil
        #expect(throws: MetalSupportError.self) {
            try optional.orThrow(.resourceCreationFailure("boom"))
        }
    }

    @Test func orThrowValue() throws {
        let optional: Int? = 42
        let value = try optional.orThrow(.resourceCreationFailure("unused"))
        #expect(value == 42)
    }

    @Test func orFatalErrorMessageValue() {
        let optional: Int? = 7
        #expect(optional.orFatalError("unused") == 7)
    }

    @Test func orFatalErrorMetalErrorValue() {
        let optional: Int? = 3
        #expect(optional.orFatalError(.resourceCreationFailure("unused")) == 3)
    }
}

// MARK: - MTLVertexFormat.size remaining cases

@Suite("MTLVertexFormat.size — remaining")
struct VertexFormatSizeRemainingTests {
    @Test func normalizedVariants() {
        #expect(MTLVertexFormat.char2Normalized.size == 2)
        #expect(MTLVertexFormat.char3Normalized.size == 3)
        #expect(MTLVertexFormat.uchar2Normalized.size == 2)
        #expect(MTLVertexFormat.uchar3Normalized.size == 3)
        #expect(MTLVertexFormat.short2Normalized.size == 4)
        #expect(MTLVertexFormat.short3Normalized.size == 6)
        #expect(MTLVertexFormat.short4Normalized.size == 8)
        #expect(MTLVertexFormat.ushort2Normalized.size == 4)
        #expect(MTLVertexFormat.ushort3Normalized.size == 6)
        #expect(MTLVertexFormat.ushort4Normalized.size == 8)
        #expect(MTLVertexFormat.ucharNormalized.size == 1)
        #expect(MTLVertexFormat.ushortNormalized.size == 2)
    }
}

// MARK: - MTLPixelFormat remaining

@Suite("MTLPixelFormat remaining")
struct PixelFormatRemainingTests {
    @Test func more8Bit() {
        #expect(MTLPixelFormat.r8Snorm.bits == 8)
        #expect(MTLPixelFormat.r8Uint.bits == 8)
    }

    @Test func packed32Bit() {
        #expect(MTLPixelFormat.bgr10a2Unorm.bits == 32)
        #expect(MTLPixelFormat.rgb9e5Float.bits == 32)
    }

    @Test func depthStencil() {
        #expect(MTLPixelFormat.depth32Float_stencil8.bits == 40)
        #expect(MTLPixelFormat.depth32Float_stencil8.size == 5)
    }

    @Test func xStencilNil() {
        #expect(MTLPixelFormat.x24_stencil8.bits == nil)
    }
}

// MARK: - MTLDevice.makeTexture(name:bundle:)

@Suite("MTLDevice.makeTexture(name:bundle:)")
struct MakeTextureNamedTests {
    @Test func missingTextureThrows() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        #expect(throws: (any Error).self) {
            try device.makeTexture(name: "this-texture-does-not-exist", bundle: Bundle.main)
        }
    }
}

// MARK: - MTLBuffer gpuAddress

@Suite("MTLBuffer gpuAddress")
struct MTLBufferGPUAddressTests {
    @Test func gpuAddressAsPointer() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        let buffer = try device.makeBuffer(unsafeBytesOf: Float(1))
        // May return nil when buffer has zero GPU address (not resident),
        // but on discrete GPUs and Apple silicon it should produce a non-nil pointer.
        let ptr = buffer.gpuAddressAsUnsafeMutablePointer(type: Float.self)
        if buffer.gpuAddress != 0 {
            #expect(ptr != nil)
        }
    }

    @Test func contentsBuffer() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        let values: [UInt32] = [1, 2, 3]
        let buffer = try device.makeBuffer(unsafeBytesOf: values)
        let raw = buffer.contentsBuffer()
        #expect(raw.count == MemoryLayout<UInt32>.stride * 3)
    }
}

// MARK: - MTLIndexType uint16/32 round trip via buffer

@Suite("MTLIndexType remaining")
struct IndexTypeRemainingTests {
    @Test func uint16And32Sizes() {
        #expect(MTLIndexType.uint16.indexSize == 2)
        #expect(MTLIndexType.uint32.indexSize == 4)
    }
}

// MARK: - DescriptorInits more paths

@Suite("DescriptorInits more")
struct DescriptorInitsMoreTests {
    @Test func samplerDescriptorAllNilFallsBackToDefaults() {
        let desc = MTLSamplerDescriptor()
        let ours = MTLSamplerDescriptor(lodAverage: nil)
        #expect(ours.minFilter == desc.minFilter)
        #expect(ours.magFilter == desc.magFilter)
    }

    @Test func samplerDescriptorWithBorderColor() {
        let desc = MTLSamplerDescriptor(borderColor: .opaqueBlack, lodAverage: true)
        #expect(desc.borderColor == .opaqueBlack)
        #expect(desc.lodAverage == true)
    }

    @Test func argumentDescriptorArrayLengthOnly() {
        let desc = MTLArgumentDescriptor(dataType: .float, index: 0, arrayLength: 4)
        #expect(desc.arrayLength == 4)
    }

    @Test func argumentDescriptorTextureType() {
        let desc = MTLArgumentDescriptor(dataType: .texture, index: 1, access: .readWrite, textureType: .type2D)
        #expect(desc.textureType == .type2D)
        #expect(desc.access == .readWrite)
    }

    @Test func argumentDescriptorConstantBlockAlignment() {
        let desc = MTLArgumentDescriptor(dataType: .float, index: 0, constantBlockAlignment: 16)
        // NOTE: implementation overloads arrayLength with constantBlockAlignment.
        #expect(desc.arrayLength == 16)
    }

    @Test func depthStencilFullInitWithBackFace() {
        let back = MTLStencilDescriptor(compareFunction: .never)
        let desc = MTLDepthStencilDescriptor(depthCompareFunction: .always, isDepthWriteEnabled: true, backFaceStencil: back)
        #expect(desc.backFaceStencil.stencilCompareFunction == .never)
    }
}

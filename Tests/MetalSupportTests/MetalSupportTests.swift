import Metal
import MetalKit
import ModelIO
import simd
import Testing

@testable import MetalSupport

// MARK: - MetalSupportError tests

@Suite("MetalSupportError")
struct MetalSupportErrorTests {
    @Test func descriptions() {
        #expect(MetalSupportError.resourceCreationFailure("texture").description == "Resource creation failure: texture")
        #expect(MetalSupportError.unexpectedError(.resourceCreationFailure("inner")).description == "Unexpected error: Resource creation failure: inner")
    }

    @Test func equatable() {
        #expect(MetalSupportError.resourceCreationFailure("a") == MetalSupportError.resourceCreationFailure("a"))
        #expect(MetalSupportError.resourceCreationFailure("a") != MetalSupportError.resourceCreationFailure("b"))
    }
}

// MARK: - MTLVertexFormat.size(packed:)

@Suite("MTLVertexFormat.size(packed:)")
struct VertexFormatSizeTests {
    @Test func float3Packed() {
        #expect(MTLVertexFormat.float3.size(packed: true) == 12)
    }

    @Test func float3Unpacked() {
        #expect(MTLVertexFormat.float3.size(packed: false) == MemoryLayout<SIMD3<Float>>.size)
    }

    @Test func float2() {
        #expect(MTLVertexFormat.float2.size(packed: true) == 8)
        #expect(MTLVertexFormat.float2.size(packed: false) == 8)
    }
}

// MARK: - MTLVertexFormat.init(MTLDataType)

@Suite("MTLVertexFormat from MTLDataType")
struct VertexFormatFromDataTypeTests {
    @Test func float3() {
        #expect(MTLVertexFormat(MTLDataType.float3) == .float3)
    }

    @Test func float2() {
        #expect(MTLVertexFormat(MTLDataType.float2) == .float2)
    }
}

// MARK: - MTLVertexFormat.init(MDLVertexFormat)

@Suite("MTLVertexFormat from MDLVertexFormat")
struct VertexFormatFromMDLTests {
    @Test func basicFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.invalid) == .invalid)
        #expect(MTLVertexFormat(MDLVertexFormat.float) == .float)
        #expect(MTLVertexFormat(MDLVertexFormat.float2) == .float2)
        #expect(MTLVertexFormat(MDLVertexFormat.float3) == .float3)
        #expect(MTLVertexFormat(MDLVertexFormat.float4) == .float4)
    }

    @Test func intFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.int) == .int)
        #expect(MTLVertexFormat(MDLVertexFormat.int2) == .int2)
        #expect(MTLVertexFormat(MDLVertexFormat.int3) == .int3)
        #expect(MTLVertexFormat(MDLVertexFormat.int4) == .int4)
        #expect(MTLVertexFormat(MDLVertexFormat.uInt) == .uint)
        #expect(MTLVertexFormat(MDLVertexFormat.uInt2) == .uint2)
        #expect(MTLVertexFormat(MDLVertexFormat.uInt3) == .uint3)
        #expect(MTLVertexFormat(MDLVertexFormat.uInt4) == .uint4)
    }

    @Test func charFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.char) == .char)
        #expect(MTLVertexFormat(MDLVertexFormat.char2) == .char2)
        #expect(MTLVertexFormat(MDLVertexFormat.char3) == .char3)
        #expect(MTLVertexFormat(MDLVertexFormat.char4) == .char4)
        #expect(MTLVertexFormat(MDLVertexFormat.uChar) == .uchar)
        #expect(MTLVertexFormat(MDLVertexFormat.uChar2) == .uchar2)
        #expect(MTLVertexFormat(MDLVertexFormat.uChar3) == .uchar3)
        #expect(MTLVertexFormat(MDLVertexFormat.uChar4) == .uchar4)
    }

    @Test func shortFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.short) == .short)
        #expect(MTLVertexFormat(MDLVertexFormat.short2) == .short2)
        #expect(MTLVertexFormat(MDLVertexFormat.short3) == .short3)
        #expect(MTLVertexFormat(MDLVertexFormat.short4) == .short4)
        #expect(MTLVertexFormat(MDLVertexFormat.uShort) == .ushort)
        #expect(MTLVertexFormat(MDLVertexFormat.uShort2) == .ushort2)
        #expect(MTLVertexFormat(MDLVertexFormat.uShort3) == .ushort3)
        #expect(MTLVertexFormat(MDLVertexFormat.uShort4) == .ushort4)
    }

    @Test func normalizedFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.charNormalized) == .charNormalized)
        #expect(MTLVertexFormat(MDLVertexFormat.char2Normalized) == .char2Normalized)
        #expect(MTLVertexFormat(MDLVertexFormat.uCharNormalized) == .ucharNormalized)
        #expect(MTLVertexFormat(MDLVertexFormat.uChar4Normalized) == .uchar4Normalized)
        #expect(MTLVertexFormat(MDLVertexFormat.shortNormalized) == .shortNormalized)
        #expect(MTLVertexFormat(MDLVertexFormat.short4Normalized) == .short4Normalized)
        #expect(MTLVertexFormat(MDLVertexFormat.uShortNormalized) == .ushortNormalized)
        #expect(MTLVertexFormat(MDLVertexFormat.uShort4Normalized) == .ushort4Normalized)
    }

    @Test func halfFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.half) == .half)
        #expect(MTLVertexFormat(MDLVertexFormat.half2) == .half2)
        #expect(MTLVertexFormat(MDLVertexFormat.half3) == .half3)
        #expect(MTLVertexFormat(MDLVertexFormat.half4) == .half4)
    }

    @Test func packedFormats() {
        #expect(MTLVertexFormat(MDLVertexFormat.int1010102Normalized) == .int1010102Normalized)
        #expect(MTLVertexFormat(MDLVertexFormat.uInt1010102Normalized) == .uint1010102Normalized)
    }
}

// MARK: - Descriptor convenience inits

@Suite("MTLDepthStencilDescriptor convenience inits")
struct DepthStencilDescriptorTests {
    @Test func initWithCompareFunction() {
        let desc = MTLDepthStencilDescriptor(depthCompareFunction: .lessEqual, isDepthWriteEnabled: false)
        #expect(desc.depthCompareFunction == .lessEqual)
        #expect(desc.isDepthWriteEnabled == false)
    }

    @Test func initWithWriteOnly() {
        let desc = MTLDepthStencilDescriptor(isDepthWriteEnabled: false)
        #expect(desc.isDepthWriteEnabled == false)
    }

    @Test func fullInit() {
        let front = MTLStencilDescriptor(compareFunction: .equal, writeMask: 0xFF)
        let desc = MTLDepthStencilDescriptor(depthCompareFunction: .greater, isDepthWriteEnabled: false, frontFaceStencil: front, label: "test")
        #expect(desc.depthCompareFunction == .greater)
        #expect(desc.isDepthWriteEnabled == false)
        #expect(desc.frontFaceStencil.stencilCompareFunction == .equal)
        #expect(desc.frontFaceStencil.writeMask == 0xFF)
        #expect(desc.label == "test")
    }
}

@Suite("MTLStencilDescriptor convenience init")
struct StencilDescriptorTests {
    @Test func customInit() {
        let desc = MTLStencilDescriptor(
            compareFunction: .notEqual,
            stencilFailureOperation: .replace,
            depthFailureOperation: .incrementClamp,
            stencilPassDepthPassOperation: .decrementClamp,
            readMask: 0x0F,
            writeMask: 0xF0
        )
        #expect(desc.stencilCompareFunction == .notEqual)
        #expect(desc.stencilFailureOperation == .replace)
        #expect(desc.depthFailureOperation == .incrementClamp)
        #expect(desc.depthStencilPassOperation == .decrementClamp)
        #expect(desc.readMask == 0x0F)
        #expect(desc.writeMask == 0xF0)
    }

    @Test func defaults() {
        let desc = MTLStencilDescriptor()
        let custom = MTLStencilDescriptor(compareFunction: .always)
        #expect(custom.stencilCompareFunction == desc.stencilCompareFunction)
        #expect(custom.stencilFailureOperation == .keep)
        #expect(custom.depthFailureOperation == .keep)
        #expect(custom.depthStencilPassOperation == .keep)
    }
}

@Suite("MTLSamplerDescriptor convenience init")
struct SamplerDescriptorTests {
    @Test func partialInit() {
        let desc = MTLSamplerDescriptor(
            minFilter: .linear,
            magFilter: .nearest,
            label: "mySampler"
        )
        #expect(desc.minFilter == .linear)
        #expect(desc.magFilter == .nearest)
        #expect(desc.label == "mySampler")
    }

    @Test func fullInit() {
        let desc = MTLSamplerDescriptor(
            minFilter: .linear,
            magFilter: .linear,
            mipFilter: .linear,
            maxAnisotropy: 8,
            sAddressMode: .repeat,
            tAddressMode: .mirrorRepeat,
            rAddressMode: .clampToZero,
            normalizedCoordinates: true,
            lodMinClamp: 0.0,
            lodMaxClamp: 10.0,
            compareFunction: .less,
            supportArgumentBuffers: true,
            label: "full"
        )
        #expect(desc.minFilter == .linear)
        #expect(desc.magFilter == .linear)
        #expect(desc.mipFilter == .linear)
        #expect(desc.maxAnisotropy == 8)
        #expect(desc.sAddressMode == .repeat)
        #expect(desc.tAddressMode == .mirrorRepeat)
        #expect(desc.rAddressMode == .clampToZero)
        #expect(desc.normalizedCoordinates == true)
        #expect(desc.lodMinClamp == 0.0)
        #expect(desc.lodMaxClamp == 10.0)
        #expect(desc.compareFunction == .less)
        #expect(desc.supportArgumentBuffers == true)
        #expect(desc.label == "full")
    }
}

// MARK: - MTLVertexDescriptor from MDLVertexDescriptor

@Suite("MTLVertexDescriptor from MDLVertexDescriptor")
struct VertexDescriptorFromMDLTests {
    @Test func basicConversion() {
        let mdl = MDLVertexDescriptor()
        let attr0 = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        let attr1 = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        mdl.attributes = NSMutableArray(array: [attr0, attr1])
        (mdl.layouts[0] as! MDLVertexBufferLayout).stride = 24

        let mtl = MTLVertexDescriptor(mdl)
        #expect(mtl.attributes[0].format == .float3)
        #expect(mtl.attributes[0].offset == 0)
        #expect(mtl.attributes[0].bufferIndex == 0)
        #expect(mtl.attributes[1].format == .float3)
        #expect(mtl.attributes[1].offset == 12)
        #expect(mtl.layouts[0].stride == 24)
    }
}

// NOTE: MTLVertexDescriptor(reflection:) tests omitted — the init uses
// withMemoryRebound on zeroed bytes and its assert fires on arm64e.
// That API needs rework before it's testable.

// MARK: - VertexDescriptor

@Suite("VertexDescriptor")
struct VertexDescriptorTests {
    @Test func attributeInit() {
        let attr = VertexDescriptor.Attribute(label: "position", semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        #expect(attr.label == "position")
        #expect(attr.semantic == .position)
        #expect(attr.format == .float3)
        #expect(attr.offset == 0)
        #expect(attr.bufferIndex == 0)
    }

    @Test func layoutInit() {
        let layout = VertexDescriptor.Layout(bufferIndex: 0, stride: 32, stepFunction: .perVertex, stepRate: 1)
        #expect(layout.bufferIndex == 0)
        #expect(layout.stride == 32)
        #expect(layout.stepFunction == .perVertex)
        #expect(layout.stepRate == 1)
    }

    @Test func layoutConvenienceInit() {
        let layout = VertexDescriptor.Layout(bufferIndex: 1)
        #expect(layout.stride == 0)
        #expect(layout.stepFunction == .perVertex)
        #expect(layout.stepRate == 1)
    }

    @Test func descriptorInit() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 12, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 24, stepFunction: .perVertex, stepRate: 1)]
        let desc = VertexDescriptor(label: "test", attributes: attrs, layouts: layouts)
        #expect(desc.label == "test")
        #expect(desc.attributes.count == 2)
        #expect(desc.layouts[0]?.stride == 24)
    }

    @Test func equatable() {
        let a1 = VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        let a2 = VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0)
        let a3 = VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 12, bufferIndex: 0)
        #expect(a1 == a2)
        #expect(a1 != a3)
    }

    @Test func normalizingOffsets() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 100, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 200, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 300, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0)]
        let normalized = VertexDescriptor(attributes: attrs, layouts: layouts).normalizingOffsets()
        #expect(normalized.attributes[0].offset == 0)
        #expect(normalized.attributes[1].offset == 12)
        #expect(normalized.attributes[2].offset == 24)
    }

    @Test func normalizingOffsetsMultipleBuffers() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 100, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 300, bufferIndex: 1),
            VertexDescriptor.Attribute(semantic: .color, format: .float4, offset: 400, bufferIndex: 1)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0), VertexDescriptor.Layout(bufferIndex: 1)]
        let normalized = VertexDescriptor(attributes: attrs, layouts: layouts).normalizingOffsets()
        #expect(normalized.attributes[0].offset == 0)
        #expect(normalized.attributes[1].offset == 0)
        #expect(normalized.attributes[2].offset == 8)
    }

    @Test func normalizingStrides() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 12, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 24, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 0, stepFunction: .perVertex, stepRate: 1)]
        let normalized = VertexDescriptor(attributes: attrs, layouts: layouts).normalizingStrides()
        #expect(normalized.layouts[0]?.stride == 32)
    }

    @Test func normalized() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 100, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 200, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 300, bufferIndex: 1),
            VertexDescriptor.Attribute(semantic: .color, format: .uchar4Normalized, offset: 400, bufferIndex: 1)
        ]
        let layouts = [
            VertexDescriptor.Layout(bufferIndex: 0, stride: 999, stepFunction: .perVertex, stepRate: 1),
            VertexDescriptor.Layout(bufferIndex: 1, stride: 888, stepFunction: .perInstance, stepRate: 3)
        ]
        let result = VertexDescriptor(attributes: attrs, layouts: layouts).normalized()
        #expect(result.attributes[0].offset == 0)
        #expect(result.attributes[1].offset == 12)
        #expect(result.layouts[0]?.stride == 24)
        #expect(result.attributes[2].offset == 0)
        #expect(result.attributes[3].offset == 8)
        #expect(result.layouts[1]?.stride == 12)
        #expect(result.layouts[1]?.stepFunction == .perInstance)
        #expect(result.layouts[1]?.stepRate == 3)
    }

    @Test func mtlVertexDescriptorConversion() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .normal, format: .float3, offset: 12, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 24, stepFunction: .perVertex, stepRate: 1)]
        let desc = VertexDescriptor(attributes: attrs, layouts: layouts)
        let mtl = desc.mtlVertexDescriptor
        #expect(mtl.attributes[0].format == .float3)
        #expect(mtl.attributes[0].offset == 0)
        #expect(mtl.attributes[1].format == .float3)
        #expect(mtl.attributes[1].offset == 12)
        #expect(mtl.layouts[0].stride == 24)
    }

    @Test func initFromMTLVertexDescriptor() {
        let mtl = MTLVertexDescriptor()
        mtl.attributes[0].format = .float3
        mtl.attributes[0].offset = 0
        mtl.attributes[0].bufferIndex = 0
        mtl.attributes[1].format = .float2
        mtl.attributes[1].offset = 12
        mtl.attributes[1].bufferIndex = 0
        mtl.layouts[0].stride = 20
        mtl.layouts[0].stepFunction = .perVertex
        mtl.layouts[0].stepRate = 1

        let desc = VertexDescriptor(mtl)
        #expect(desc.attributes.count == 2)
        #expect(desc.attributes[0].format == .float3)
        #expect(desc.attributes[0].offset == 0)
        #expect(desc.attributes[1].format == .float2)
        #expect(desc.attributes[1].offset == 12)
        #expect(desc.layouts[0]?.stride == 20)
    }

    @Test func roundTrip() {
        let attrs = [
            VertexDescriptor.Attribute(semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(semantic: .texcoord, format: .float2, offset: 12, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 20, stepFunction: .perVertex, stepRate: 1)]
        let original = VertexDescriptor(attributes: attrs, layouts: layouts)
        let roundTrip = VertexDescriptor(original.mtlVertexDescriptor)
        #expect(roundTrip.attributes.count == 2)
        #expect(roundTrip.attributes[0].format == .float3)
        #expect(roundTrip.attributes[1].format == .float2)
        #expect(roundTrip.attributes[1].offset == 12)
        #expect(roundTrip.layouts[0]?.stride == 20)
    }

    @Test func codable() throws {
        let attrs = [
            VertexDescriptor.Attribute(label: "pos", semantic: .position, format: .float3, offset: 0, bufferIndex: 0),
            VertexDescriptor.Attribute(label: "uv", semantic: .texcoord, format: .float2, offset: 12, bufferIndex: 0)
        ]
        let layouts = [VertexDescriptor.Layout(bufferIndex: 0, stride: 20, stepFunction: .perVertex, stepRate: 1)]
        let original = VertexDescriptor(label: "test", attributes: attrs, layouts: layouts)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(VertexDescriptor.self, from: data)
        #expect(decoded == original)
    }
}

// MARK: - MTLVertexFormat.size

@Suite("MTLVertexFormat.size")
struct VertexFormatSizePropertyTests {
    @Test func floatSizes() {
        #expect(MTLVertexFormat.float.size == 4)
        #expect(MTLVertexFormat.float2.size == 8)
        #expect(MTLVertexFormat.float3.size == 12)
        #expect(MTLVertexFormat.float4.size == 16)
    }

    @Test func halfSizes() {
        #expect(MTLVertexFormat.half.size == 2)
        #expect(MTLVertexFormat.half2.size == 4)
        #expect(MTLVertexFormat.half3.size == 6)
        #expect(MTLVertexFormat.half4.size == 8)
    }

    @Test func intSizes() {
        #expect(MTLVertexFormat.int.size == 4)
        #expect(MTLVertexFormat.int2.size == 8)
        #expect(MTLVertexFormat.int3.size == 12)
        #expect(MTLVertexFormat.int4.size == 16)
        #expect(MTLVertexFormat.uint.size == 4)
        #expect(MTLVertexFormat.uint2.size == 8)
        #expect(MTLVertexFormat.uint3.size == 12)
        #expect(MTLVertexFormat.uint4.size == 16)
    }

    @Test func shortSizes() {
        #expect(MTLVertexFormat.short.size == 2)
        #expect(MTLVertexFormat.short2.size == 4)
        #expect(MTLVertexFormat.short3.size == 6)
        #expect(MTLVertexFormat.short4.size == 8)
        #expect(MTLVertexFormat.ushort.size == 2)
        #expect(MTLVertexFormat.ushort2.size == 4)
        #expect(MTLVertexFormat.ushort3.size == 6)
        #expect(MTLVertexFormat.ushort4.size == 8)
    }

    @Test func charSizes() {
        #expect(MTLVertexFormat.char.size == 1)
        #expect(MTLVertexFormat.char2.size == 2)
        #expect(MTLVertexFormat.char3.size == 3)
        #expect(MTLVertexFormat.char4.size == 4)
        #expect(MTLVertexFormat.uchar.size == 1)
        #expect(MTLVertexFormat.uchar2.size == 2)
        #expect(MTLVertexFormat.uchar3.size == 3)
        #expect(MTLVertexFormat.uchar4.size == 4)
    }

    @Test func normalizedSizes() {
        #expect(MTLVertexFormat.charNormalized.size == 1)
        #expect(MTLVertexFormat.uchar4Normalized.size == 4)
        #expect(MTLVertexFormat.shortNormalized.size == 2)
        #expect(MTLVertexFormat.ushort4Normalized.size == 8)
        #expect(MTLVertexFormat.uchar4Normalized_bgra.size == 4)
    }

    @Test func packedSizes() {
        #expect(MTLVertexFormat.int1010102Normalized.size == 4)
        #expect(MTLVertexFormat.uint1010102Normalized.size == 4)
        #expect(MTLVertexFormat.floatRG11B10.size == 4)
        #expect(MTLVertexFormat.floatRGB9E5.size == 4)
    }
}

// MARK: - GPU-dependent tests (require Metal device)

@Suite("GPU-dependent tests")
struct GPUTests {
    let device: MTLDevice

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalSupportError.resourceCreationFailure("No Metal device available")
        }
        self.device = device
    }

    @Test func createSystemDefaultDevice() {
        let device = _MTLCreateSystemDefaultDevice()
        #expect(device.name.isEmpty == false)
    }

    @Test func makeCommandQueue() throws {
        let queue = try device._makeCommandQueue()
        #expect(queue.device === device)
    }

    @Test func makeTexture() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 16, height: 16, mipmapped: false)
        desc.storageMode = .shared
        let texture = try device._makeTexture(descriptor: desc)
        #expect(texture.width == 16)
        #expect(texture.height == 16)
    }

    @Test func makeBufferFromValue() throws {
        let value: SIMD4<Float> = [1, 2, 3, 4]
        let buffer = try device.makeBuffer(unsafeBytesOf: value)
        #expect(buffer.length == MemoryLayout<SIMD4<Float>>.size)
    }

    @Test func makeBufferFromArray() throws {
        let values: [Float] = [1, 2, 3, 4]
        let buffer = try device.makeBuffer(unsafeBytesOf: values)
        #expect(buffer.length == MemoryLayout<Float>.stride * 4)
    }

    @Test func makeBufferFromCollection() throws {
        let values: [SIMD2<Float>] = [[1, 2], [3, 4]]
        let buffer = try device.makeBuffer(collection: values, options: [])
        #expect(buffer.length == MemoryLayout<SIMD2<Float>>.stride * 2)
    }

    @Test func bufferContents() throws {
        let values: [Float] = [1, 2, 3, 4]
        let buffer = try device.makeBuffer(unsafeBytesOf: values)
        let contents: UnsafeBufferPointer<Float> = buffer.contents()
        #expect(contents.count == 4)
        #expect(contents[0] == 1)
        #expect(contents[3] == 4)
    }

    @Test func bufferLabeled() throws {
        let values: [Float] = [1]
        let buffer = try device.makeBuffer(unsafeBytesOf: values).labeled("test")
        #expect(buffer.label == "test")
    }

    @Test func make1PixelTexture() throws {
        let texture = try device.make1PixelTexture(color: [1, 0, 0, 1])
        #expect(texture.width == 1)
        #expect(texture.height == 1)
        #expect(texture.pixelFormat == .rgba8Unorm)
    }

    @Test func makeTextureRepeating() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: 4, height: 4, mipmapped: false)
        desc.storageMode = .shared
        let texture = try device.makeTexture(descriptor: desc, repeating: Float(3.14))
        #expect(texture.width == 4)
        #expect(texture.height == 4)
    }

    @Test func textureToCGImage() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: 2, height: 2, mipmapped: false)
        desc.storageMode = .shared
        desc.usage = [.shaderRead, .shaderWrite]
        let texture = try device._makeTexture(descriptor: desc)
        let pixels: [UInt8] = Array(repeating: 255, count: 2 * 2 * 4)
        pixels.withUnsafeBytes { ptr in
            texture.replace(region: MTLRegionMake2D(0, 0, 2, 2), mipmapLevel: 0, withBytes: ptr.baseAddress!, bytesPerRow: 2 * 4)
        }
        let cgImage = try texture.toCGImage()
        #expect(cgImage.width == 2)
        #expect(cgImage.height == 2)
    }

    @Test func makeSamplerState() throws {
        let desc = MTLSamplerDescriptor(minFilter: .linear, magFilter: .linear)
        let sampler = try device._makeSamplerState(descriptor: desc)
        #expect(sampler.device === device)
    }

    @Test func bufferData() throws {
        let values: [UInt8] = [1, 2, 3, 4]
        let buffer = try device.makeBuffer(unsafeBytesOf: values)
        let data = buffer.data()
        #expect(data.count == 4)
        #expect([UInt8](data) == values)
    }

    @Test func bufferWith() throws {
        let buffer = try device.makeBuffer(unsafeBytesOf: Float(0))
        buffer.with(type: Float.self) { value in
            value = 42.0
        }
        let contents: UnsafeBufferPointer<Float> = buffer.contents()
        #expect(contents[0] == 42.0)
    }

    @Test func bufferWithEx() throws {
        let values: [Int32] = [10, 20, 30]
        let buffer = try device.makeBuffer(unsafeBytesOf: values)
        buffer.withEx(type: Int32.self, count: 3) { ptr in
            ptr[1] = 99
        }
        let contents: UnsafeBufferPointer<Int32> = buffer.contents()
        #expect(contents[0] == 10)
        #expect(contents[1] == 99)
        #expect(contents[2] == 30)
    }

    @Test func textureSize() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 8, height: 16, mipmapped: false)
        desc.storageMode = .shared
        let texture = try device._makeTexture(descriptor: desc)
        #expect(texture.size.width == 8)
        #expect(texture.size.height == 16)
        #expect(texture.size.depth == 1)
    }

    @Test func textureRegion() throws {
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        desc.storageMode = .shared
        let texture = try device._makeTexture(descriptor: desc)
        let region = texture.region
        #expect(region.origin.x == 0)
        #expect(region.origin.y == 0)
        #expect(region.size.width == 4)
        #expect(region.size.height == 4)
    }

    @Test func supportsNonuniformThreadGroupSizes() {
        // Just verify it returns without crashing
        _ = device.supportsNonuniformThreadGroupSizes
    }
}

// MARK: - MTLPixelFormat

@Suite("MTLPixelFormat")
struct PixelFormatTests {
    @Test func bits8() {
        #expect(MTLPixelFormat.r8Unorm.bits == 8)
        #expect(MTLPixelFormat.a8Unorm.bits == 8)
        #expect(MTLPixelFormat.stencil8.bits == 8)
    }

    @Test func bits16() {
        #expect(MTLPixelFormat.r16Float.bits == 16)
        #expect(MTLPixelFormat.rg8Unorm.bits == 16)
        #expect(MTLPixelFormat.b5g6r5Unorm.bits == 16)
        #expect(MTLPixelFormat.depth16Unorm.bits == 16)
    }

    @Test func bits32() {
        #expect(MTLPixelFormat.rgba8Unorm.bits == 32)
        #expect(MTLPixelFormat.bgra8Unorm.bits == 32)
        #expect(MTLPixelFormat.r32Float.bits == 32)
        #expect(MTLPixelFormat.rgb10a2Unorm.bits == 32)
        #expect(MTLPixelFormat.depth32Float.bits == 32)
    }

    @Test func bits64() {
        #expect(MTLPixelFormat.rgba16Float.bits == 64)
        #expect(MTLPixelFormat.rg32Float.bits == 64)
    }

    @Test func bits128() {
        #expect(MTLPixelFormat.rgba32Float.bits == 128)
    }

    @Test func size() {
        #expect(MTLPixelFormat.rgba8Unorm.size == 4)
        #expect(MTLPixelFormat.rgba16Float.size == 8)
        #expect(MTLPixelFormat.rgba32Float.size == 16)
        #expect(MTLPixelFormat.r8Unorm.size == 1)
    }

    @Test func nilCases() {
        #expect(MTLPixelFormat.x32_stencil8.bits == nil)
        #expect(MTLPixelFormat.x32_stencil8.size == nil)
    }
}

// MARK: - MTLGeometry convenience inits

@Suite("MTLGeometry")
struct GeometryTests {
    @Test func originZero() {
        let o = MTLOrigin.zero
        #expect(o.x == 0)
        #expect(o.y == 0)
        #expect(o.z == 0)
    }

    @Test func originFromCGPoint() {
        let o = MTLOrigin(CGPoint(x: 10, y: 20))
        #expect(o.x == 10)
        #expect(o.y == 20)
        #expect(o.z == 0)
    }

    @Test func sizeComponents() {
        let s = MTLSize(3, 5, 7)
        #expect(s.width == 3)
        #expect(s.height == 5)
        #expect(s.depth == 7)
    }

    @Test func sizeFromCGSize() {
        let s = MTLSize(CGSize(width: 100, height: 200))
        #expect(s.width == 100)
        #expect(s.height == 200)
        #expect(s.depth == 1)
    }

    @Test func regionFromCGRect() {
        let r = MTLRegion(CGRect(x: 5, y: 10, width: 20, height: 30))
        #expect(r.origin.x == 5)
        #expect(r.origin.y == 10)
        #expect(r.size.width == 20)
        #expect(r.size.height == 30)
    }
}

// MARK: - MTLIndexType / MTLPrimitiveType

@Suite("MTLIndexType and MTLPrimitiveType")
struct IndexAndPrimitiveTests {
    @Test func indexSize() {
        #expect(MTLIndexType.uint16.indexSize == 2)
        #expect(MTLIndexType.uint32.indexSize == 4)
    }

    @Test func vertexCount() {
        #expect(MTLPrimitiveType.point.vertexCount == 1)
        #expect(MTLPrimitiveType.line.vertexCount == 2)
        #expect(MTLPrimitiveType.triangle.vertexCount == 3)
        #expect(MTLPrimitiveType.lineStrip.vertexCount == nil)
        #expect(MTLPrimitiveType.triangleStrip.vertexCount == nil)
    }
}

// MARK: - Descriptor inits (Argument / Attribute)

@Suite("Descriptor inits")
struct NewDescriptorInitTests {
    @Test func argumentDescriptor() {
        let desc = MTLArgumentDescriptor(dataType: .float4, index: 3, access: .readOnly)
        #expect(desc.dataType == .float4)
        #expect(desc.index == 3)
        #expect(desc.access == .readOnly)
    }

    @Test func attributeDescriptor() {
        let desc = MTLAttributeDescriptor(format: .float3, offset: 12, bufferIndex: 2)
        #expect(desc.format == .float3)
        #expect(desc.offset == 12)
        #expect(desc.bufferIndex == 2)
    }

    @Test func attributeDescriptorDefaults() {
        let desc = MTLAttributeDescriptor(format: .float2, bufferIndex: 0)
        #expect(desc.offset == 0)
    }
}

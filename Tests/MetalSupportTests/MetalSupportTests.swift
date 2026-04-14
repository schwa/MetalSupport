import Metal
import MetalKit
import ModelIO
import simd
import Testing

@testable import MetalSupport

// MARK: - isPOD tests

@Suite("isPOD")
struct IsPODTests {
    @Test func podTypes() {
        #expect(isPOD(Float.self))
        #expect(isPOD(Int.self))
        #expect(isPOD(SIMD4<Float>.self))
        #expect(isPOD(UInt8.self))
    }

    @Test func podValues() {
        #expect(isPOD(42.0 as Float))
        #expect(isPOD(SIMD3<Float>(1, 2, 3)))
    }

    @Test func podArrays() {
        #expect(isPODArray([Float]()))
        #expect(isPODArray([1, 2, 3] as [Int32]))
    }

    @Test func nonPodTypes() {
        #expect(!isPOD(String.self))
        #expect(!isPOD([Int].self))
    }
}

// MARK: - MetalSupportError tests

@Suite("MetalSupportError")
struct MetalSupportErrorTests {
    @Test func descriptions() {
        #expect(MetalSupportError.undefined.description == "Undefined error")
        #expect(MetalSupportError.generic("boom").description == "boom")
        #expect(MetalSupportError.resourceCreationFailure("texture").description == "Resource creation failure: texture")
        #expect(MetalSupportError.unexpectedError(.undefined).description == "Unexpected error: Undefined error")
    }

    @Test func equatable() {
        #expect(MetalSupportError.undefined == MetalSupportError.undefined)
        #expect(MetalSupportError.generic("a") == MetalSupportError.generic("a"))
        #expect(MetalSupportError.generic("a") != MetalSupportError.generic("b"))
    }
}

// MARK: - Optional helpers

@Suite("Optional helpers")
struct OptionalHelperTests {
    @Test func orThrowWithValue() throws {
        let value: Int? = 42
        let result = try value.orThrow(.undefined)
        #expect(result == 42)
    }

    @Test func orThrowWithNil() {
        let value: Int? = nil
        #expect(throws: MetalSupportError.self) {
            try value.orThrow(.resourceCreationFailure("missing"))
        }
    }

    @Test func orFatalErrorWithValue() {
        let value: Int? = 42
        let result = value.orFatalError("should not fail")
        #expect(result == 42)
    }

    @Test func orFatalErrorWithErrorAndValue() {
        let value: Int? = 42
        let result = value.orFatalError(.undefined)
        #expect(result == 42)
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
}

import CoreGraphics
import Metal
import simd
import ModelIO

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable file_length
// swiftlint:disable function_parameter_count

#if os(macOS)
    public func allHeadlessDevices() -> [MTLDevice] {
        MTLCopyAllDevices().filter { $0.isHeadless == true }
    }

    public func allLowPowerDevices() -> [MTLDevice] {
        MTLCopyAllDevices().filter { $0.isLowPower == true }
    }
#endif

public extension MTLAttributeDescriptor {
    convenience init(format: MTLAttributeFormat, offset: Int = 0, bufferIndex: Int) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}

public extension MTLTexture {
    var size: MTLSize {
        MTLSize(width, height, depth)
    }

    var region: MTLRegion {
        MTLRegion(origin: .zero, size: size)
    }
}

public extension MTLPixelFormat {
    var bits: Int? {
        switch self {
        /* Normal 8 bit formats */
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return 8
        /* Normal 16 bit formats */
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint:
            return 16
        /* Packed 16 bit formats */
        case .b5g6r5Unorm, .a1bgr5Unorm, .abgr4Unorm, .bgr5A1Unorm:
            return 16
        /* Normal 32 bit formats */
        case .r32Uint, .r32Sint, .r32Float, .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float, .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb:
            return 32
        /* Packed 32 bit formats */
        case .rgb10a2Unorm, .rgb10a2Uint, .rg11b10Float, .rgb9e5Float, .bgr10a2Unorm, .bgr10_xr, .bgr10_xr_srgb:
            return 32
        /* Normal 64 bit formats */
        case .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float, .bgra10_xr, .bgra10_xr_srgb:
            return 64
        /* Normal 128 bit formats */
        case .rgba32Uint, .rgba32Sint, .rgba32Float:
            return 128
        /* Depth */
        case .depth16Unorm:
            return 16
        case .depth32Float:
            return 32
        /* Stencil */
        case .stencil8:
            return 8
        /* Depth Stencil */
        case .depth24Unorm_stencil8:
            return 32
        case .depth32Float_stencil8:
            return 40
        case .x32_stencil8:
            return nil
        case .x24_stencil8:
            return nil
        default:
            return nil
        }
    }

    var size: Int? {
        bits.map { $0 / 8 }
    }
}

public extension MTLOrigin {
    static var zero: MTLOrigin {
        MTLOrigin(x: 0, y: 0, z: 0)
    }
}

public extension MTLSize {
    init(_ width: Int, _ height: Int, _ depth: Int) {
        self = MTLSize(width: width, height: height, depth: depth)
    }
}

public extension MTLDevice {
    @available(*, deprecated, message: "TODO")
    func make2DTexture(pixelFormat: MTLPixelFormat = .rgba8Unorm, size: SIMD2<Int>, mipmapped: Bool = false, usage: MTLTextureUsage? = nil) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: size.x, height: size.y, mipmapped: mipmapped)
        if let usage {
            textureDescriptor.usage = usage
        }
        return makeTexture(descriptor: textureDescriptor)!
    }
}

public extension MTLTexture {
    func clear(color: SIMD4<UInt8> = [0, 0, 0, 0]) {
        assert(depth == 1)
        let buffer = Array(repeatElement(color, count: width * height * depth))
        assert(MemoryLayout<SIMD4<UInt8>>.stride == pixelFormat.size)
        buffer.withUnsafeBytes { pointer in
            replace(region: region, mipmapLevel: 0, withBytes: pointer.baseAddress!, bytesPerRow: width * MemoryLayout<SIMD4<UInt8>>.stride)
        }
    }
}

public extension MTLBuffer {
    func data() -> Data {
        Data(bytes: contents(), count: length)
    }
}

public extension MTLPrimitiveType {
    var vertexCount: Int? {
        switch self {
        case .triangle:
            return 3
        default:
            fatal(error: MetalSupportError.illegalValue)
        }
    }
}

public extension CGSize {
    init(_ size: SIMD2<Double>) {
        self = CGSize(width: CGFloat(size.x), height: CGFloat(size.y))
    }
}

public extension MTLIndexType {
    var indexSize: Int {
        switch self {
        case .uint16:
            return MemoryLayout<UInt16>.size
        case .uint32:
            return MemoryLayout<UInt32>.size
        default:
            fatal(error: MetalSupportError.illegalValue)
        }
    }
}

public extension MTLDevice {
    func makeBuffer(bytesOf content: some Any, options: MTLResourceOptions) -> MTLBuffer? {
        withUnsafeBytes(of: content) { buffer in
            makeBuffer(bytes: buffer.baseAddress!, length: buffer.count, options: .storageModeShared)
        }
    }

    func makeBuffer(bytesOf content: [some Any], options: MTLResourceOptions) -> MTLBuffer? {
        content.withUnsafeBytes { buffer in
            makeBuffer(bytes: buffer.baseAddress!, length: buffer.count, options: .storageModeShared)
        }
    }
}

extension MTLGPUFamily: CaseIterable, CustomStringConvertible {
    public var description: String {
        switch self {
        case .apple1: return "apple1"
        case .apple2: return "apple2"
        case .apple3: return "apple3"
        case .apple4: return "apple4"
        case .apple5: return "apple5"
        case .apple6: return "apple6"
        case .apple7: return "apple7"
        case .mac1: return "mac1"
        case .mac2: return "mac2"
        case .common1: return "common1"
        case .common2: return "common2"
        case .common3: return "common3"
        case .macCatalyst1: return "macCatalyst1"
        case .macCatalyst2: return "macCatalyst2"
        case .apple8:
            return "apple8"
        case .metal3:
            return "metal3"
        @unknown default:
            fatalError("Unknown MTLGPUFamily")
        }
    }

    public static var allCases: [MTLGPUFamily] {
        [
            .apple1,
            .apple2,
            .apple3,
            .apple4,
            .apple5,
            .apple6,
            .apple7,
            .apple8,
            .mac2,
            .common1,
            .common2,
            .common3,
            //.metal3, // TODO: fix me
        ]
    }
}

public extension MTLArgumentEncoder {
    func setBytesOf<Value>(_ value: Value, index: Int) {
        let d = constantData(at: index).bindMemory(to: Value.self, capacity: 1)
        d.pointee = value
    }
}

extension MTLSize: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let width = try container.decode(Int.self)
        let height = try container.decode(Int.self)
        let depth = try container.decode(Int.self)
        self = MTLSize(width: width, height: height, depth: depth)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(width)
        try container.encode(height)
        try container.encode(depth)
    }
}

extension MTLWinding: CaseIterable, CustomStringConvertible {
    public static var allCases: [MTLWinding] = [.clockwise, .counterClockwise]

    public var description: String {
        switch self {
        case .clockwise:
            return "clockwise"
        case .counterClockwise:
            return "counterClockwise"
        @unknown default:
            fatalError("Unexpected case")
        }
    }
}

extension MTLCullMode: CaseIterable, CustomStringConvertible {
    public static var allCases: [MTLCullMode] = [.back, .front, .none]

    public var description: String {
        switch self {
        case .back:
            return "back"
        case .front:
            return "front"
        case .none:
            return "none"
        @unknown default:
            fatalError("Unexpected case")
        }
    }
}

extension MTLTriangleFillMode: CaseIterable {
    public static var allCases: [MTLTriangleFillMode] = [.fill, .lines]
}

extension MTLTriangleFillMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fill: return "fill"
        case .lines: return "lines"
        default:
            fatalError("Unexpected case")
        }
    }
}

public extension MTLRenderCommandEncoder {
    func setVertexBytes(of value: some Any, index: Int) {
        withUnsafeBytes(of: value) { buffer in
            setVertexBytes(buffer.baseAddress!, length: buffer.count, index: index)
        }
    }

    func setVertexBytes(of value: [some Any], index: Int) {
        value.withUnsafeBytes { buffer in
            setVertexBytes(buffer.baseAddress!, length: buffer.count, index: index)
        }
    }

    func setFragmentBytes(of value: some Any, index: Int) {
        withUnsafeBytes(of: value) { buffer in
            setFragmentBytes(buffer.baseAddress!, length: buffer.count, index: index)
        }
    }

    func setFragmentBytes(of value: [some Any], index: Int) {
        value.withUnsafeBytes { buffer in
            setFragmentBytes(buffer.baseAddress!, length: buffer.count, index: index)
        }
    }
}

public extension MTLBuffer {
    /// Update a MTLBuffer's contents using an inout type block
    func with<T, R>(type: T.Type, _ block: (inout T) -> R) -> R {
        let value = contents().bindMemory(to: T.self, capacity: 1)
        let result = block(&value.pointee)
        return result
    }

    func withEx<T, R>(type: T.Type, count: Int, _ block: (UnsafeMutableBufferPointer<T>) -> R) -> R {
        let pointer = contents().bindMemory(to: T.self, capacity: count)
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: count)
        let result = block(buffer)
        return result
    }
}

extension MTLCompareFunction: CaseIterable, CustomStringConvertible {
    public static var allCases: [MTLCompareFunction] = [
        .never,
        .less,
        .equal,
        .lessEqual,
        .greater,
        .notEqual,
        .greaterEqual,
        .always,
    ]

    public var description: String {
        switch self {
        case .never: return "never"
        case .less: return "less"
        case .equal: return "equal"
        case .lessEqual: return "lessEqual"
        case .greater: return "greater"
        case .notEqual: return "notEqual"
        case .greaterEqual: return "greaterEqual"
        case .always: return "always"
        @unknown default:
            fatalError("Unexpected case")
        }
    }
}

// NOTE: Deprecate?
public extension MTLDevice {
    // @available(*, deprecated, message: "Do not use. Should be an extension on blit encoder")
    func copy(from sourceBuffer: MTLBuffer, sourceOffset: Int, to destinationBuffer: MTLBuffer, destinationOffset: Int, size: Int) {
        let commandQueue = makeCommandQueue()!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeBlitCommandEncoder()!
        commandEncoder.copy(from: sourceBuffer, sourceOffset: sourceOffset, to: destinationBuffer, destinationOffset: destinationOffset, size: size)
        commandEncoder.endEncoding()
        commandBuffer.commit()
    }

    // @available(*, deprecated, message: "Do not use. Should be an extension on blit encoder")
    func makePrivateCopy(of sourceBuffer: MTLBuffer) -> MTLBuffer {
        let privateBuffer = makeBuffer(length: sourceBuffer.length, options: .storageModePrivate)!
        privateBuffer.label = "\(sourceBuffer.label ?? "Unlabeled buffer") private copy"
        copy(from: sourceBuffer, sourceOffset: 0, to: privateBuffer, destinationOffset: 0, size: sourceBuffer.length)
        return privateBuffer
    }
}

extension MTLResourceUsage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let strings = try container.decode([String].self)
        let mapping = [
            "read": MTLResourceUsage.read,
            "write": MTLResourceUsage.write,
        ]
        assert(!strings.contains("sample"))
        let usages: [MTLResourceUsage] = strings.map { mapping[$0]! }
        self = MTLResourceUsage(usages)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let mapping = [
            (MTLResourceUsage.read, "read"),
            (MTLResourceUsage.write, "write"),
        ]
        let strings = mapping.compactMap { contains($0.0) ? $0.1 : nil }
        try container.encode(strings)
    }
}

public extension MTLVertexDescriptor {
    // TODO: Only works for SIMPLE vertexes (one layout)
    convenience init(attributes: [MTLVertexAttribute]) {
        self.init()
        var offset = 0
        for (index, attribute) in attributes.enumerated() {
            let attributeDescriptor = MTLVertexAttributeDescriptor()
            attributeDescriptor.offset = offset
            attributeDescriptor.format = MTLVertexFormat(dataType: attribute.attributeType)!
            self.attributes[index] = attributeDescriptor
            offset += attributeDescriptor.format.size
        }
        layouts[0].stride = offset
    }
}

public extension MTLVertexFormat {
    var size: Int {
        switch self {
        case .uchar, .ucharNormalized:
            return MemoryLayout<UInt8>.size
        case .uchar2, .uchar2Normalized:
            return 2 * MemoryLayout<UInt8>.size
        case .uchar3, .uchar3Normalized:
            return 3 * MemoryLayout<UInt8>.size
        case .uchar4, .uchar4Normalized:
            return 4 * MemoryLayout<UInt8>.size
        case .char, .charNormalized:
            return MemoryLayout<Int8>.size
        case .char2, .char2Normalized:
            return 2 * MemoryLayout<Int8>.size
        case .char3, .char3Normalized:
            return 3 * MemoryLayout<Int8>.size
        case .char4, .char4Normalized:
            return 4 * MemoryLayout<Int8>.size
        case .ushort, .ushortNormalized:
            return MemoryLayout<UInt16>.size
        case .ushort2, .ushort2Normalized:
            return 2 * MemoryLayout<UInt16>.size
        case .ushort3, .ushort3Normalized:
            return 3 * MemoryLayout<UInt16>.size
        case .ushort4, .ushort4Normalized:
            return 4 * MemoryLayout<UInt16>.size
        case .short, .shortNormalized:
            return MemoryLayout<Int16>.size
        case .short2, .short2Normalized:
            return 2 * MemoryLayout<Int16>.size
        case .short3, .short3Normalized:
            return 3 * MemoryLayout<Int16>.size
        case .short4, .short4Normalized:
            return 4 * MemoryLayout<Int16>.size
        case .half:
#if arch(arm64)
            return MemoryLayout<Float16>.size
#else
            return MemoryLayout<Int16>.size
#endif
        case .half2:
#if arch(arm64)
            return 2 * MemoryLayout<Float16>.size
#else
            return 2 * MemoryLayout<Int16>.size
#endif
        case .half3:
#if arch(arm64)
            return 3 * MemoryLayout<Float16>.size
#else
            return 3 * MemoryLayout<Int16>.size
#endif
        case .half4:
#if arch(arm64)
            return MemoryLayout<Float16>.size
#else
            return MemoryLayout<Int16>.size
#endif
        case .float:
            return MemoryLayout<Float>.size
        case .float2:
            return 2 * MemoryLayout<Float>.size
        case .float3:
            return 3 * MemoryLayout<Float>.size
        case .float4:
            return 4 * MemoryLayout<Float>.size
        case .int:
            return MemoryLayout<Int32>.size
        case .int2:
            return 2 * MemoryLayout<Int32>.size
        case .int3:
            return 3 * MemoryLayout<Int32>.size
        case .int4:
            return 4 * MemoryLayout<UInt32>.size
        case .uint:
            return MemoryLayout<UInt32>.size
        case .uint2:
            return 2 * MemoryLayout<UInt32>.size
        case .uint3:
            return 3 * MemoryLayout<UInt32>.size
        case .uint4:
            return 4 * MemoryLayout<UInt32>.size
        case .int1010102Normalized, .uint1010102Normalized:
            return MemoryLayout<UInt32>.size
        case .uchar4Normalized_bgra:
            return 4 * MemoryLayout<UInt8>.size
        default:
            fatalError("Unknown MTLVertexFormat \(self)")
        }
    }
}

public extension MTLVertexFormat {
    init?(dataType: MTLDataType) {
        switch dataType {
        case .float2:
            self = .float2
        case .float3:
            self = .float3
        case .float4:
            self = .float4
        case .half:
            self = .half
        case .half2:
            self = .half2
        case .half3:
            self = .half3
        case .half4:
            self = .half4
        case .int:
            self = .int
        case .int2:
            self = .int2
        case .int3:
            self = .int3
        case .int4:
            self = .int4
        case .uint:
            self = .uint
        case .uint2:
            self = .uint2
        case .uint3:
            self = .uint3
        case .uint4:
            self = .uint4
        case .short:
            self = .short
        case .short2:
            self = .short2
        case .short3:
            self = .short3
        case .short4:
            self = .short4
        case .ushort:
            self = .ushort
        case .ushort2:
            self = .ushort2
        case .ushort3:
            self = .ushort3
        case .ushort4:
            self = .ushort4
        case .char:
            self = .char
        case .char2:
            self = .char2
        case .char3:
            self = .char3
        case .char4:
            self = .char4
        case .uchar:
            self = .uchar
        case .uchar2:
            self = .uchar
        case .uchar3:
            self = .uchar3
        case .uchar4:
            self = .uchar4
        default:
            fatalError("Unsupported or unknown MTLDataType.")
        }
    }
}

public extension MTLArgumentDescriptor {
    convenience init(dataType: MTLDataType, index: Int, arrayLength: Int? = nil, access: MTLBindingAccess? = nil, textureType: MTLTextureType? = nil, constantBlockAlignment: Int? = nil) {
        self.init()
        self.dataType = dataType
        self.index = index
        if let arrayLength {
            self.arrayLength = arrayLength
        }
        if let access {
            self.access = access
        }
        if let textureType {
            self.textureType = textureType
        }
        if let constantBlockAlignment {
            self.arrayLength = constantBlockAlignment
        }
    }
}

public extension MTLVertexDescriptor {
    convenience init(vertexDescriptor: MDLVertexDescriptor) {
        self.init()
        for (index, mdlAttribute) in vertexDescriptor.attributes.enumerated() {
            let mdlAttribute = mdlAttribute as! MDLVertexAttribute
            attributes[index].offset = mdlAttribute.offset
            attributes[index].bufferIndex = mdlAttribute.bufferIndex
            attributes[index].format = MTLVertexFormat(mdlAttribute.format)
        }
        for (index, mdlLayout) in vertexDescriptor.layouts.enumerated() {
            let mdlLayout = mdlLayout as! MDLVertexBufferLayout
            layouts[index].stride = mdlLayout.stride
        }
    }
}

extension MTLSize: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        assert(elements.count == 3)
        self = MTLSize(elements[0], elements[1], elements[2])
    }
}

public extension MTLDevice {
    var supportsNonuniformThreadGroupSizes: Bool {
        let families: [MTLGPUFamily] = [.apple4, .apple5, .apple6, .apple7]
        return families.contains { supportsFamily($0) }
    }
}

public extension MTLDevice {
    func makeTexture2D<T>(width: Int, height: Int, pixelFormat: MTLPixelFormat, storageMode: MTLStorageMode, usage: MTLTextureUsage, pixels: [T], label: String? = nil) -> MTLTexture {
        return pixels.withUnsafeBytes { bytes -> MTLTexture in
            let descriptor = MTLTextureDescriptor()
            descriptor.width = width
            descriptor.height = height
            descriptor.pixelFormat = pixelFormat
            descriptor.storageMode = storageMode
            descriptor.usage = usage

            var bufferOptions: MTLResourceOptions = []
            let buffer: MTLBuffer
            if storageMode == .shared {
                bufferOptions.insert(.storageModeShared)
                buffer = makeBuffer(bytes: bytes.baseAddress!, length: bytes.count, options: bufferOptions)!
                buffer.label = label
            }
            else {
                let sharedBuffer = makeBuffer(bytes: bytes.baseAddress!, length: bytes.count, options: .storageModeShared)!
                buffer = makePrivateCopy(of: sharedBuffer)
                buffer.label = label
            }

            let texture = buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: descriptor.width * MemoryLayout<T>.stride)!
            texture.label = label
            return texture
        }
    }
}

public extension MTLRenderCommandEncoder {
    func setVertexBuffer<T>(_ buffer: MTLBuffer?, offset: Int, index: T) where T: RawRepresentable, T.RawValue == Int {
        setVertexBuffer(buffer, offset: offset, index: index.rawValue)
    }

    func setFragmentBuffer<T>(_ buffer: MTLBuffer?, offset: Int, index: T) where T: RawRepresentable, T.RawValue == Int {
        setFragmentBuffer(buffer, offset: offset, index: index.rawValue)
    }

    func setVertexTexture<T>(_ texture: MTLTexture?, index: T) where T: RawRepresentable, T.RawValue == Int {
        setVertexTexture(texture, index: index.rawValue)
    }

    func setFragmentTexture<T>(_ texture: MTLTexture?, index: T) where T: RawRepresentable, T.RawValue == Int {
        setFragmentTexture(texture, index: index.rawValue)
    }
}

public extension MTLComputeCommandEncoder {
    func setBuffer<T>(_ buffer: MTLBuffer?, offset: Int, index: T) where T: RawRepresentable, T.RawValue == Int {
        setBuffer(buffer, offset: offset, index: index.rawValue)
    }

    func setTexture<T>(_ texture: MTLTexture?, index: T) where T: RawRepresentable, T.RawValue == Int {
        setTexture(texture, index: index.rawValue)
    }

    func setBytes<T>(_ bytes: UnsafeRawPointer, length: Int, index: T) where T: RawRepresentable, T.RawValue == Int {
        setBytes(bytes, length: length, index: index.rawValue)
    }
}

public extension MTLRenderCommandEncoder {
    func setBuffer(_ buffer: MTLBuffer?, offset: Int, stage: MTLRenderStages, index: Int) {
        switch stage {
        case .vertex:
            setVertexBuffer(buffer, offset: offset, index: index)
        case .fragment:
            setFragmentBuffer(buffer, offset: offset, index: index)
        default:
            fatalError("Unexpected case")
        }
    }

    func setBytes(_ bytes: UnsafeRawPointer, length: Int, stage: MTLRenderStages, index: Int) {
        switch stage {
        case .vertex:
            setVertexBytes(bytes, length: length, index: index)
        case .fragment:
            setFragmentBytes(bytes, length: length, index: index)
        default:
            fatalError("Unexpected case")
        }
    }

    func setBytes(_ buffer: UnsafeRawBufferPointer, stage: MTLRenderStages, index: Int) {
        setBytes(buffer.baseAddress!, length: buffer.count, stage: stage, index: index)
    }

    func setTexture(_ value: MTLTexture?, stage: MTLRenderStages, index: Int) {
        switch stage {
        case .vertex:
            setVertexTexture(value, index: index)
        case .fragment:
            setFragmentTexture(value, index: index)
        default:
            fatalError("Unexpected case")
        }
    }

    func setSamplerState(_ value: MTLSamplerState?, stage: MTLRenderStages, index: Int) {
        switch stage {
        case .vertex:
            setVertexSamplerState(value, index: index)
        case .fragment:
            setFragmentSamplerState(value, index: index)
        default:
            fatalError("Unexpected case")
        }
    }
}

public extension MTLRenderCommandEncoder {
    func setBytes(of value: some Any, stage: MTLRenderStages, index: Int) {
        withUnsafeBytes(of: value) { (buffer: UnsafeRawBufferPointer) in
            setBytes(buffer, stage: stage, index: index)
        }
    }

    func setBytes(of array: [some Any], stage: MTLRenderStages, index: Int) {
        array.withUnsafeBytes { buffer in
            setBytes(buffer, stage: stage, index: index)
        }
    }
}

// MARK: -

public extension MTLComputeCommandEncoder {
    func setBytes(_ bytes: UnsafeRawBufferPointer, index: Int) {
        setBytes(bytes.baseAddress!, length: bytes.count, index: index)
    }
}

public extension MTLComputeCommandEncoder {
    func setBytes(of value: some Any, index: Int) {
        withUnsafeBytes(of: value) { (buffer: UnsafeRawBufferPointer) in
            setBytes(buffer, index: index)
        }
    }

    func setBytes(of array: [some Any], index: Int) {
        array.withUnsafeBytes { buffer in
            setBytes(buffer, index: index)
        }
    }
}

extension MTLResourceUsage: Hashable {
}

extension MTLRenderStages: Hashable {
}


import Metal
import OrderedCollections

/// A lightweight, `Codable`, `Sendable` vertex layout description with semantic annotations.
public struct VertexDescriptor: Equatable, Sendable {
    /// A single vertex attribute within a descriptor.
    public struct Attribute: Equatable, Sendable {
        /// The semantic role of a vertex attribute.
        public enum Semantic: Equatable, Sendable, Codable {
            case unknown
            case position
            case normal
            case tangent
            case bitangent
            case texcoord
            case color
            case userDefined
        }

        /// An optional human-readable label.
        public var label: String?
        /// The semantic role of this attribute.
        public var semantic: Semantic
        /// The vertex format.
        public var format: MTLVertexFormat
        /// The byte offset within the buffer.
        public var offset: Int
        /// The index of the buffer this attribute reads from.
        public var bufferIndex: Int

        /// Creates an attribute.
        public init(label: String? = nil, semantic: Semantic, format: MTLVertexFormat, offset: Int, bufferIndex: Int) {
            self.label = label
            self.semantic = semantic
            self.format = format
            self.offset = offset
            self.bufferIndex = bufferIndex
        }
    }

    /// A vertex buffer layout within a descriptor.
    public struct Layout: Equatable, Sendable {
        /// The buffer index this layout describes.
        public var bufferIndex: Int
        /// The stride in bytes between consecutive vertices.
        public var stride: Int
        /// How the vertex data steps (per-vertex, per-instance, etc.).
        public var stepFunction: MTLVertexStepFunction
        /// The rate at which the step function advances.
        public var stepRate: Int

        /// Creates a layout.
        public init(bufferIndex: Int, stride: Int, stepFunction: MTLVertexStepFunction, stepRate: Int) {
            self.bufferIndex = bufferIndex
            self.stride = stride
            self.stepFunction = stepFunction
            self.stepRate = stepRate
        }
    }

    /// An optional human-readable label.
    public var label: String?
    /// The vertex attributes.
    public var attributes: [Attribute]
    /// The buffer layouts, keyed by buffer index.
    public var layouts: OrderedDictionary<Int, Layout>

    /// Creates a vertex descriptor.
    public init(label: String? = nil, attributes: [Attribute], layouts: [Layout]) {
        self.label = label
        self.attributes = attributes
        self.layouts = .init(uniqueKeysWithValues: layouts.map { ($0.bufferIndex, $0) })
    }
}

extension VertexDescriptor: CustomDebugStringConvertible {
    public var debugDescription: String {
        "VertexDescriptor(\(label.map { "label: \($0), " } ?? "")attributes: \(attributes), layouts: \(layouts))"
    }
}

extension VertexDescriptor.Attribute: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Attribute(\(label.map { "label: \($0), " } ?? "")semantic: \(semantic), format: \(format), offset: \(offset), bufferIndex: \(bufferIndex))"
    }
}

extension VertexDescriptor.Layout: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Layout(bufferIndex: \(bufferIndex), stride: \(stride), stepFunction: \(stepFunction), stepRate: \(stepRate))"
    }
}

public extension VertexDescriptor.Layout {
    /// Creates a layout with default stride (0), per-vertex stepping, and step rate 1.
    init(bufferIndex: Int) {
        self.init(bufferIndex: bufferIndex, stride: 0, stepFunction: .perVertex, stepRate: 1)
    }
}

public extension VertexDescriptor {
    /// Prints the descriptor to standard output for debugging.
    func dump() {
        print("VertexDescriptor: \(label ?? "nil")")
        print("Attributes:")
        for attribute in attributes {
            print("  - \(attribute)")
        }
        print("Layouts:")
        for layout in layouts.values {
            print("  - \(layout)")
        }
    }
}

public extension VertexDescriptor {
    /// Returns a copy with both offsets and strides normalized.
    func normalized() -> Self {
        normalizingOffsets().normalizingStrides()
    }

    /// Returns a copy with attribute offsets recomputed sequentially per buffer.
    func normalizingOffsets() -> Self {
        var copy = self
        var offsetsPerBufferIndex: [Int: Int] = [:]
        copy.attributes = copy.attributes.map { attribute in
            let currentOffset = offsetsPerBufferIndex[attribute.bufferIndex, default: 0]
            var attribute = attribute
            attribute.offset = currentOffset
            offsetsPerBufferIndex[attribute.bufferIndex] = currentOffset + attribute.format.size
            return attribute
        }
        return copy
    }

    /// Returns a copy with layout strides computed from attribute offsets and sizes.
    func normalizingStrides() -> Self {
        var copy = self
        for (bufferIndex, layout) in copy.layouts {
            let maxOffset = copy.attributes
                .filter { $0.bufferIndex == bufferIndex }
                .map { $0.offset + $0.format.size }
                .max() ?? 0
            var layout = layout
            layout.stride = maxOffset
            copy.layouts[bufferIndex] = layout
        }
        return copy
    }
}

public extension VertexDescriptor {
    /// Creates a vertex descriptor from an `MTLVertexDescriptor`.
    init(_ mtlVertexDescriptor: MTLVertexDescriptor) {
        var attributes: [Attribute] = []
        var layouts: [Layout] = []

        // Convert attributes
        for index in 0..<31 { // Metal supports up to 31 vertex attributes
            guard let mtlAttribute = mtlVertexDescriptor.attributes[index], mtlAttribute.format != .invalid else {
                continue
            }

            let attribute = Attribute(
                label: nil,
                semantic: .userDefined, // We can't infer semantic from MTLVertexDescriptor
                format: mtlAttribute.format,
                offset: mtlAttribute.offset,
                bufferIndex: mtlAttribute.bufferIndex
            )
            attributes.append(attribute)
        }

        // Convert layouts
        for bufferIndex in 0..<31 { // Metal supports up to 31 vertex buffer layouts
            guard let mtlLayout = mtlVertexDescriptor.layouts[bufferIndex], mtlLayout.stride > 0 else {
                continue
            }

            let layout = Layout(
                bufferIndex: bufferIndex,
                stride: mtlLayout.stride,
                stepFunction: mtlLayout.stepFunction,
                stepRate: mtlLayout.stepRate
            )
            layouts.append(layout)
        }

        self.init(label: nil, attributes: attributes, layouts: layouts)
    }

    /// Converts to an `MTLVertexDescriptor`.
    var mtlVertexDescriptor: MTLVertexDescriptor {
        let mtlVertexDescriptor = MTLVertexDescriptor()
        for (index, attribute) in attributes.enumerated() {
            let mtlAttribute = mtlVertexDescriptor.attributes[index]
                .orFatalError("Missing MTL attribute descriptor at index \(index)")
            mtlAttribute.format = attribute.format
            mtlAttribute.offset = attribute.offset
            mtlAttribute.bufferIndex = attribute.bufferIndex
        }
        for (bufferIndex, layout) in layouts {
            let mtlLayout = mtlVertexDescriptor.layouts[bufferIndex]
                .orFatalError("Missing MTL layout descriptor at index \(bufferIndex)")
            mtlLayout.stride = layout.stride
            mtlLayout.stepFunction = layout.stepFunction
            mtlLayout.stepRate = layout.stepRate
        }
        return mtlVertexDescriptor
    }
}

public extension MTLVertexDescriptor {
    /// Creates an `MTLVertexDescriptor` from a ``VertexDescriptor``.
    convenience init(_ vertexDescriptor: VertexDescriptor) {
        self.init()

        // Set up attributes
        for (index, attribute) in vertexDescriptor.attributes.enumerated() {
            let mtlAttribute = attributes[index]
                .orFatalError("Missing MTL attribute descriptor at index \(index)")
            mtlAttribute.format = attribute.format
            mtlAttribute.offset = attribute.offset
            mtlAttribute.bufferIndex = attribute.bufferIndex
        }

        // Set up layouts
        for (bufferIndex, layout) in vertexDescriptor.layouts {
            let mtlLayout = layouts[bufferIndex]
                .orFatalError("Missing MTL layout descriptor at index \(bufferIndex)")
            mtlLayout.stride = layout.stride
            mtlLayout.stepFunction = layout.stepFunction
            mtlLayout.stepRate = layout.stepRate
        }
    }
}

// MARK: - Codable

extension VertexDescriptor.Attribute: Codable {
    enum CodingKeys: String, CodingKey {
        case label
        case semantic
        case format
        case offset
        case bufferIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        semantic = try container.decode(Semantic.self, forKey: .semantic)
        let formatRawValue = try container.decode(UInt.self, forKey: .format)
        format = MTLVertexFormat(rawValue: formatRawValue) ?? .invalid
        offset = try container.decode(Int.self, forKey: .offset)
        bufferIndex = try container.decode(Int.self, forKey: .bufferIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encode(semantic, forKey: .semantic)
        try container.encode(format.rawValue, forKey: .format)
        try container.encode(offset, forKey: .offset)
        try container.encode(bufferIndex, forKey: .bufferIndex)
    }
}

extension VertexDescriptor.Layout: Codable {
    enum CodingKeys: String, CodingKey {
        case bufferIndex
        case stride
        case stepFunction
        case stepRate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bufferIndex = try container.decode(Int.self, forKey: .bufferIndex)
        stride = try container.decode(Int.self, forKey: .stride)
        let stepFunctionRawValue = try container.decode(UInt.self, forKey: .stepFunction)
        stepFunction = MTLVertexStepFunction(rawValue: stepFunctionRawValue) ?? .perVertex
        stepRate = try container.decode(Int.self, forKey: .stepRate)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bufferIndex, forKey: .bufferIndex)
        try container.encode(stride, forKey: .stride)
        try container.encode(stepFunction.rawValue, forKey: .stepFunction)
        try container.encode(stepRate, forKey: .stepRate)
    }
}

extension VertexDescriptor: Codable {
    enum CodingKeys: String, CodingKey {
        case label
        case attributes
        case layouts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        attributes = try container.decode([Attribute].self, forKey: .attributes)
        let layoutsArray = try container.decode([Layout].self, forKey: .layouts)
        layouts = .init(uniqueKeysWithValues: layoutsArray.map { ($0.bufferIndex, $0) })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(Array(layouts.values), forKey: .layouts)
    }
}

// MARK: -

public extension MTLVertexFormat {
    /// The byte size of a single element of this vertex format (packed, no SIMD alignment padding).
    var size: Int {
        switch self {
        case .invalid:
            fatalError("Invalid vertex format")

        case .uchar2:
            return MemoryLayout<UInt8>.size * 2

        case .uchar3:
            return MemoryLayout<UInt8>.size * 3

        case .uchar4:
            return MemoryLayout<UInt8>.size * 4

        case .char2:
            return MemoryLayout<Int8>.size * 2

        case .char3:
            return MemoryLayout<Int8>.size * 3

        case .char4:
            return MemoryLayout<Int8>.size * 4

        case .uchar2Normalized:
            return MemoryLayout<UInt8>.size * 2

        case .uchar3Normalized:
            return MemoryLayout<UInt8>.size * 3

        case .uchar4Normalized:
            return MemoryLayout<UInt8>.size * 4

        case .char2Normalized:
            return MemoryLayout<Int8>.size * 2

        case .char3Normalized:
            return MemoryLayout<Int8>.size * 3

        case .char4Normalized:
            return MemoryLayout<Int8>.size * 4

        case .ushort2:
            return MemoryLayout<UInt16>.size * 2

        case .ushort3:
            return MemoryLayout<UInt16>.size * 3

        case .ushort4:
            return MemoryLayout<UInt16>.size * 4

        case .short2:
            return MemoryLayout<Int16>.size * 2

        case .short3:
            return MemoryLayout<Int16>.size * 3

        case .short4:
            return MemoryLayout<Int16>.size * 4

        case .ushort2Normalized:
            return MemoryLayout<UInt16>.size * 2

        case .ushort3Normalized:
            return MemoryLayout<UInt16>.size * 3

        case .ushort4Normalized:
            return MemoryLayout<UInt16>.size * 4

        case .short2Normalized:
            return MemoryLayout<Int16>.size * 2

        case .short3Normalized:
            return MemoryLayout<Int16>.size * 3

        case .short4Normalized:
            return MemoryLayout<Int16>.size * 4

        case .half2:
            return MemoryLayout<Float16>.size * 2

        case .half3:
            return MemoryLayout<Float16>.size * 3

        case .half4:
            return MemoryLayout<Float16>.size * 4

        case .float:
            return MemoryLayout<Float>.size

        case .float2:
            return MemoryLayout<Float>.size * 2

        case .float3:
            return MemoryLayout<Float>.size * 3

        case .float4:
            return MemoryLayout<Float>.size * 4

        case .int:
            return MemoryLayout<Int32>.size

        case .int2:
            return MemoryLayout<Int32>.size * 2

        case .int3:
            return MemoryLayout<Int32>.size * 3

        case .int4:
            return MemoryLayout<Int32>.size * 4

        case .uint:
            return MemoryLayout<UInt32>.size

        case .uint2:
            return MemoryLayout<UInt32>.size * 2

        case .uint3:
            return MemoryLayout<UInt32>.size * 3

        case .uint4:
            return MemoryLayout<UInt32>.size * 4

        case .int1010102Normalized:
            return MemoryLayout<UInt32>.size

        case .uint1010102Normalized:
            return MemoryLayout<UInt32>.size

        case .uchar4Normalized_bgra:
            return MemoryLayout<UInt8>.size * 4

        case .uchar:
            return MemoryLayout<UInt8>.size

        case .char:
            return MemoryLayout<Int8>.size

        case .ucharNormalized:
            return MemoryLayout<UInt8>.size

        case .charNormalized:
            return MemoryLayout<Int8>.size

        case .ushort:
            return MemoryLayout<UInt16>.size

        case .short:
            return MemoryLayout<Int16>.size

        case .ushortNormalized:
            return MemoryLayout<UInt16>.size

        case .shortNormalized:
            return MemoryLayout<Int16>.size

        case .half:
            return MemoryLayout<Float16>.size

        case .floatRG11B10:
            return MemoryLayout<UInt32>.size

        case .floatRGB9E5:
            return MemoryLayout<UInt32>.size

        @unknown default:
            fatalError("Unknown vertex format")
        }
    }
}

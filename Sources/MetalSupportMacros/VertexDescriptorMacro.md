# VertexDescriptorMacro

The ``VertexDescriptor`` and ``VertexAttribute`` macros work in tandem to provide a simple way to define a Metal vertex descriptor (``MTLVertexDescriptor``) for a Swift struct. Writing a vertex descriptor is boilerplate and an excellent candidate for the use of Swift macros. It's very easy to get a vertex descriptor wrong and the macro system should be able to catch many of these errors at compile time.

## Usage

Add the ``@VertexDescriptor`` macro decorator to any swift struct to add automatic conformance to the ``VertexDescriptorProviding`` protocol. The swift struct must only contain simple types that are compatible with Metal and/or SIMD. The macro will then infer the vertex attributes for all member variables within the struct. You can also use the ``@VertexAttribute`` macro decorator to specify the format of a member variable if the ``VertexDescriptor`` macro can't infer it.

## Example

This input...

```swift
@VertexDescriptor
struct MyVertex {
    // Don't specify anything - let macro infer
    var position: SIMD3<Float>
    // Tell the macro what the attribute type is if it can't infer
    @VertexAttribute(.float4)
    var ambient: (Float, Float, Float, Float)

    // Specify the buffer index explicitely (otherwise 0 is assumed)
    @VertexAttribute(bufferIndex: 1)
    var specular: SIMD4<Float>

    // Specify both format and buffer index. Note there is a mismatch here and the macro system _should_ catch it
    @VertexAttribute(.float4, bufferIndex: 1)
    var texture: SIMD2<Float>
}
```

should produce output like this...

```swift
struct MyVertex: VertexDescriptorProviding {
    var position: SIMD3<Float>
    var ambient: (Float, Float, Float, Float)
    var specular: SIMD4<Float>
    var texture: SIMD2<Float>

    static let descriptor: MTLVertexDescriptor {
        let d = MTLVertexDescriptor()
        // Attribute for ``position``: ``SIMD3<Float>``
        d.attributes[0].format = .float3
        d.attributes[0].offset = 0
        d.attributes[0].bufferIndex = 0
        // Attribute for ``ambient``: ``(Float, Float, Float, Float)``
        d.attributes[1].format = .float4
        d.attributes[1].offset = 12
        d.attributes[1].bufferIndex = 0
        // Attribute for ``specular``: ``SIMD4<Float>``
        d.attributes[2].format = .float4
        d.attributes[2].offset = 0
        d.attributes[2].bufferIndex = 1
        // Attribute for ``texture``: ``SIMD2<Float>``
        d.attributes[3].format = .float4 // TODO: note the mismatch
        d.attributes[3].offset = 16
        d.attributes[3].bufferIndex = 1

        d.layouts[0].stride = 26
        d.layouts[1].stride = 32
        return d
    }
}
```

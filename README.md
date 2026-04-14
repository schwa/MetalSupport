# MetalSupport

Swift utility extensions for Metal development.

## Vertex Descriptor Conversions

Most Metal rendering pipelines need an `MTLVertexDescriptor`. MetalSupport provides converters from several source types so you can get there from wherever you're starting:

```
                 MDLVertexDescriptor
                       │
                       ▼
MTLFunction ──▶ MTLVertexDescriptor ◀──▶ VertexDescriptor
                    ▲         ▲
                    │         │
          [MTLVertexAttribute]   Swift struct (reflection)
```

| From | To | How |
|------|----|-----|
| `VertexDescriptor` | `MTLVertexDescriptor` | `MTLVertexDescriptor(descriptor)` or `.mtlVertexDescriptor` |
| `MTLVertexDescriptor` | `VertexDescriptor` | `VertexDescriptor(mtlDescriptor)` |
| `MDLVertexDescriptor` | `MTLVertexDescriptor` | `MTLVertexDescriptor(mdlDescriptor)` |
| `MDLVertexFormat` | `MTLVertexFormat` | `MTLVertexFormat(mdlFormat)` |
| `MTLDataType` | `MTLVertexFormat` | `MTLVertexFormat(dataType)` |
| `[MTLVertexAttribute]` | `MTLVertexDescriptor` | `MTLVertexDescriptor(vertexAttributes:)` |
| `MTLFunction` | `MTLVertexDescriptor?` | `.inferredVertexDescriptor()` |
| Swift struct | `MTLVertexDescriptor` | `MTLVertexDescriptor(reflection: MyVertex.self)` |

`VertexDescriptor` is a lightweight, `Codable`, `Sendable` value type with semantic annotations and normalization helpers — useful when you need to inspect, serialize, or manipulate vertex layouts before converting to the final `MTLVertexDescriptor`.

# ISSUES.md

---

## 1: Deduplicate setUnsafeBytes boilerplate in UnsafeBytes.swift

+++
status: new
priority: low
kind: enhancement
labels: architecture, code-duplication
created: 2026-04-14T21:13:14Z
+++

UnsafeBytes.swift contains 10 nearly-identical methods on MTLRenderCommandEncoder (vertex/fragment/object/mesh × value/array) plus 2 on MTLComputeCommandEncoder. Each repeats the same withUnsafeBytes → baseAddress → setXxxBytes pattern. Extract a single generic helper to reduce duplication and make the pattern testable.

---

## 2: Remove or rework MTLVertexDescriptor.init(reflection:)

+++
status: new
priority: medium
kind: bug
labels: architecture, vertex-descriptor, broken
created: 2026-04-14T21:13:14Z
+++

The reflection-based MTLVertexDescriptor.init(reflection:) uses withMemoryRebound on zeroed bytes + Mirror, which is inherently unsafe. The test file notes 'its assert fires on arm64e. That API needs rework before it is testable.' It also duplicates type→format knowledge from other files. Either fix it properly or remove it.

---

## 3: Consolidate vertex format size tables

+++
status: new
priority: medium
kind: enhancement
labels: architecture, vertex-descriptor
created: 2026-04-14T21:13:27Z
+++

Three separate exhaustive switch statements map MTLVertexFormat to byte sizes: MTLVertexFormat.size in VertexDescriptor.swift, MTLVertexFormat.size(packed:) in MTLVertexFormat+Extensions.swift, and inferredVertexDescriptor() in MTLFunction+Extensions.swift. The reflection-based MTLVertexDescriptor.init(reflection:) duplicates the same type-to-format+size mapping again. Unify into a single source of truth.

---

## 4: Extract Labeled protocol to replace copy-pasted labeled(_:) methods

+++
status: new
priority: low
kind: enhancement
labels: architecture, code-duplication
created: 2026-04-14T21:13:38Z
+++

Labeled.swift has five identical labeled(_:) methods copy-pasted across MTLCommandQueue, MTLCommandBuffer, MTLRenderCommandEncoder, MTLTexture, and MTLBuffer. These could be a single protocol extension on anything with a settable label property.

---

## 5: Deduplicate withDebugGroup methods in DebugGroup.swift

+++
status: new
priority: low
kind: enhancement
labels: architecture, code-duplication
created: 2026-04-14T21:13:44Z
+++

Four identical withDebugGroup methods on MTLCommandBuffer, MTLRenderCommandEncoder, MTLComputeCommandEncoder, and MTLBlitCommandEncoder. Same pattern, same body, same signature. Could be unified via a protocol.

---

## 6: Investigate MTLLogState failure on CI runners

+++
status: new
priority: low
kind: task
labels: testing,ci,metal
created: 2026-04-19T19:51:47Z
+++

The `commandBufferDescriptorDefaultLogging()` test in `Tests/MetalSupportTests/CommandBufferAndQueueTests.swift` is currently disabled on CI (gated on the `CI` env var) because `MTLLogState` creation fails on GitHub Actions macOS runners with:

```
MTLLogStateErrorDomain Code=2 "Cannot create residency set for MTLLogState"
```

Investigate:
- Why residency sets fail on GitHub Actions runners (virtualized/headless GPU?).
- Whether a different `MTLLogStateDescriptor` config avoids the residency-set path.
- Whether there's a way to exercise `addDefaultLogging()` on CI without triggering this error, or restructure the API so the residency-set-requiring bits are separately testable.
- If nothing changes upstream, document the CI limitation in the code comment near the `@Test(.disabled(...))` attribute.

See commit a9b7addd for the disable.

---

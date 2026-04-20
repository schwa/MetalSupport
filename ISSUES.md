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
labels: testing, ci, metal
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

## 7: Add MTLTexture.setTexture() API for memset-equivalent texture clearing

+++
status: closed
priority: medium
kind: feature
created: 2026-04-20T18:06:42Z
updated: 2026-04-20T18:44:13Z
closed: 2026-04-20T18:44:13Z
+++

Add a `MTLTexture.fill(...)`-style API that performs a memset-equivalent fill on a texture.

## API

Three overloads on `MTLTexture`, all generic over a POD `T`:

```swift
// Shared/managed only — uses replace(region:...) directly.
func fill<T>(
    with value: T,
    region: MTLRegion? = nil,
    mipmapLevel: Int = 0,
    slice: Int = 0
) throws

// Caller supplies an existing blit encoder (piggy-back).
func fill<T>(
    with value: T,
    region: MTLRegion? = nil,
    mipmapLevel: Int = 0,
    slice: Int = 0,
    using encoder: MTLBlitCommandEncoder
) throws

// Caller supplies a queue — we create our own command buffer + blit encoder,
// commit(), and waitUntilCompleted() so the call is synchronous.
func fill<T>(
    with value: T,
    region: MTLRegion? = nil,
    mipmapLevel: Int = 0,
    slice: Int = 0,
    using queue: MTLCommandQueue
) throws
```

Defaults: `region == nil` means the full texture region at the given mip/slice.

## Behavior

- **`.shared` / `.managed`**: use `texture.replace(region:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:)` directly, no encoder needed.
- **`.private`**: allocate a staging `MTLBuffer` sized to the full target region, fill it with the repeated pattern, then `blitEncoder.copy(from:buffer, ... to:texture, ...)` in a single copy.
- **`.memoryless`**: throw.

For the queue overload, label the auto-created command buffer and blit encoder (e.g. `"MTLTexture.fill"`).

## Supporting work

- Add `MTLPixelFormat.size` (bytes-per-pixel) helper in `MTLPixelFormat+Extensions.swift`. Useful elsewhere (e.g. `toCGImage` currently hardcodes `width * 4`).

## Validation / error surface

- `MemoryLayout<T>.stride != pixelFormat.size` → **throw** (`MetalSupportError`).
- `.memoryless` storage → **throw** (`unsupportedStorageMode` or similar).
- Depth/stencil pixel formats → **throw** (out of scope for v1, `unsupportedPixelFormat`).
- Compressed formats (BC/ASTC/etc.) → **throw** (out of scope for v1).
- `_isPOD(T.self) == false` → **precondition**.
- Region/mip/slice out of bounds → **precondition** (matches Metal's own behavior).
- Staging buffer allocation failure → **throw** (`resourceCreationFailure`).

Add new `MetalSupportError` cases as needed.

## Tests

1. Shared texture, `bgra8Unorm`, fill with a known `UInt32` color → `getBytes` and verify every pixel.
2. Private texture via queue overload → blit back to a shared texture (or equivalent) and verify.
3. Private texture via caller-supplied blit encoder → same verification.
4. Stride mismatch throws (e.g. pass `UInt16` to a `bgra8Unorm` texture).
5. Sub-region fill: only the region changes; surrounding pixels untouched.
6. Mip level > 0 fill works.

Out of scope for v1: `.memoryless`, cube/array slices, non-`waitUntilCompleted` variants, color-convenience overload (e.g. `SIMD4<Float>`).

- `2026-04-20T18:44:13Z`: Implemented in ef5717c8. Depth/stencil support tracked separately in #8.

---

## 8: Support depth/stencil pixel formats in MTLTexture.fill()

+++
status: new
priority: low
kind: enhancement
created: 2026-04-20T18:34:15Z
+++

Follow-up to #7. The initial `MTLTexture.fill()` implementation throws `unsupportedPixelFormat` for depth/stencil formats:

- `.depth16Unorm`
- `.depth32Float`
- `.stencil8`
- `.depth24Unorm_stencil8`
- `.depth32Float_stencil8`
- `.x32_stencil8`
- `.x24_stencil8`

These were deferred because blit-from-buffer into depth/stencil textures has extra rules (alignment, combined depth+stencil packing, platform-specific availability of `.depth24Unorm_stencil8`, and `x*_stencil8` being stencil-only views).

## Scope

- Investigate the correct approach per format (blit-from-buffer with the right alignment, or a render pass with `loadAction = .clear` and a configured `clearDepth` / `clearStencil`).
- Handle combined depth+stencil formats correctly (may require two passes or a packed buffer layout).
- Handle the `x*_stencil8` stencil-only views.
- Add tests for each supported format.
- Update error messaging / documentation for any formats that remain unsupported.

---

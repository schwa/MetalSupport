import Metal

public extension MTLPixelFormat {
    /// The number of bits per pixel, or `nil` for formats without a fixed size.
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

        case .x32_stencil8, .x24_stencil8:
            return nil

        default:
            return nil
        }
    }

    /// The number of bytes per pixel, or `nil` for formats without a fixed size.
    var size: Int? {
        bits.map { $0 / 8 }
    }
}

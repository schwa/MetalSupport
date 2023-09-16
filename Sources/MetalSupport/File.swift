import simd

func hslToRgb(_ h: Float, _ s: Float, _ l: Float) -> SIMD3<Float> {
    if s == 0 {
        return [1, 1, 1]
    } else {
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        let r = hueToRgb(p, q, h + 1 / 3)
        let g = hueToRgb(p, q, h)
        let b = hueToRgb(p, q, h - 1 / 3)
        return [r, g, b]
    }
}

func hueToRgb(_ p: Float, _ q: Float, _ t: Float) -> Float {
    var t = t
    if t < 0 { t += 1 }
    if t > 1 { t -= 1 }
    if t < 1 / 6 { return p + (q - p) * 6 * t }
    if t < 1 / 2 { return q }
    if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
    return p
}


public enum MetalSupportError: Error {
    case illegalValue
}

internal func fatal(error: Error) -> Never {
    fatalError("\(error)")
}


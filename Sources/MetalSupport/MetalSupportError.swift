import Foundation

/// An error thrown by MetalSupport operations.
public indirect enum MetalSupportError: Error, Equatable {
    /// A Metal or system resource could not be created.
    case resourceCreationFailure(String)
    /// The caller-supplied value's byte size did not match the texture's pixel stride.
    case invalidPixelStride(String)
    /// The texture's pixel format is not supported by this operation.
    case unsupportedPixelFormat(String)
    /// The texture's storage mode is not supported by this operation.
    case unsupportedStorageMode(String)
    /// Wraps another ``MetalSupportError`` that was not expected.
    case unexpectedError(Self)
}

extension MetalSupportError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .resourceCreationFailure(let message):
            return "Resource creation failure: \(message)"

        case .invalidPixelStride(let message):
            return "Invalid pixel stride: \(message)"

        case .unsupportedPixelFormat(let message):
            return "Unsupported pixel format: \(message)"

        case .unsupportedStorageMode(let message):
            return "Unsupported storage mode: \(message)"

        case .unexpectedError(let error):
            return "Unexpected error: \(error)"
        }
    }
}

extension Optional {
    func orThrow(_ error: @autoclosure () -> MetalSupportError) throws -> Wrapped {
        // swiftlint:disable:next self_binding
        guard let value = self else {
            throw error()
        }
        return value
    }

    func orFatalError(_ message: @autoclosure () -> String = String()) -> Wrapped {
        // swiftlint:disable:next self_binding
        guard let value = self else {
            fatalError(message())
        }
        return value
    }

    func orFatalError(_ error: @autoclosure () -> MetalSupportError) -> Wrapped {
        // swiftlint:disable:next self_binding
        guard let value = self else {
            fatalError("\(error())")
        }
        return value
    }
}

import Foundation

/// An error thrown by MetalSupport operations.
public indirect enum MetalSupportError: Error, Equatable {
    /// An unspecified error.
    case undefined
    /// A general-purpose error with a descriptive message.
    case generic(String)
    /// A Metal or system resource could not be created.
    case resourceCreationFailure(String)
    /// Wraps another ``MetalSupportError`` that was not expected.
    case unexpectedError(Self)
}

extension MetalSupportError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undefined:
            return "Undefined error"

        case .generic(let message):
            return message

        case .resourceCreationFailure(let message):
            return "Resource creation failure: \(message)"

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

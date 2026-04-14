import Foundation

public indirect enum MetalSupportError: Error, Equatable {
    case undefined
    case generic(String)
    case resourceCreationFailure(String)
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

public extension Optional {
    func orThrow(_ error: @autoclosure () -> MetalSupportError) throws -> Wrapped {
        guard let value = self else {
            throw error()
        }
        return value
    }

    func orFatalError(_ message: @autoclosure () -> String = String()) -> Wrapped {
        guard let value = self else {
            fatalError(message())
        }
        return value
    }

    func orFatalError(_ error: @autoclosure () -> MetalSupportError) -> Wrapped {
        guard let value = self else {
            fatalError("\(error())")
        }
        return value
    }
}

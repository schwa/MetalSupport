import Foundation

public func isPOD<T>(_ type: T.Type) -> Bool {
    _isPOD(type)
}

public func isPOD<T>(_: T) -> Bool {
    _isPOD(T.self)
}

public func isPODArray<T>(_: [T]) -> Bool {
    _isPOD(T.self)
}

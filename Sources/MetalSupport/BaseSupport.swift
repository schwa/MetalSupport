import Foundation

func isPOD<T>(_ type: T.Type) -> Bool {
    _isPOD(type)
}

func isPOD<T>(_: T) -> Bool {
    _isPOD(T.self)
}

func isPODArray<T>(_: [T]) -> Bool {
    _isPOD(T.self)
}

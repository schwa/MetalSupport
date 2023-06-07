import SwiftDiagnostics
import SwiftSyntax

enum MacroError: Error {
    case generic(String)
}

enum MetalSupportDiagnostic: DiagnosticMessage {
    var message: String {
        switch self {
        case .generic(let message):
            return message
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .generic:
            return MessageID(domain: "MetalSupport", id: "generic")
        }
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .generic:
            return .error
        }
    }

    @available(*, deprecated, message: "Generic is lazy. Add cases.")
    case generic(String)
}


extension VariableDeclSyntax {
  /// Determine whether this variable has the syntax of a stored property.
  ///
  /// This syntactic check cannot account for semantic adjustments due to,
  /// e.g., accessor macros or property wrappers.
  var isStoredProperty: Bool {
    if bindings.count != 1 {
      return false
    }

    let binding = bindings.first!
    switch binding.accessor {
    case .none:
      return true

    case .accessors(let node):
      for accessor in node.accessors {
        switch accessor.accessorKind.tokenKind {
        case .keyword(.willSet), .keyword(.didSet):
          // Observers can occur on a stored property.
          break

        default:
          // Other accessors make it a computed property.
          return false
        }
      }

      return true

    case .getter:
      return false
    }
  }
}


extension TupleExprElementListSyntax  {
    func element(at index: Int) -> ExprSyntax? {
        // TODO: return nil if index out of bounds
        let index = self.index(self.startIndex, offsetBy: index)
        return self[index].expression
    }

    func element(labeled label: String) -> ExprSyntax? {
        first { element in
            element.label?.trimmedDescription == label
        }?.expression
    }
}

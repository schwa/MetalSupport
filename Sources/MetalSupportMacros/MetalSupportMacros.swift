import Metal
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum MacroError: Error {
    case generic(String)
}

// MARK: -

public struct VertexDescriptorMacro {
}

extension VertexDescriptorMacro: MemberAttributeMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
        // Nothing to do here except consume the macro. Processing of macro is actually in MemberMacro
        return []
    }
}

extension VertexDescriptorMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        print("#####", Self.self, #function)
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            //            context.diagnose(Diagnostic(node: node, message: )
            //            return []
            throw MacroError.generic("@\(node.attributeName) can only be applied to a struct")
        }
        let attributes = try structDecl.memberBlock.members.compactMap { member -> VertexAttribute? in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            return try VertexAttribute(variableDecl)
        }
        let descriptor = VertexDescriptor(attributes: attributes)
        return descriptor.source(name: "d")
    }
}

extension VertexDescriptorMacro: ConformanceMacro {
    public static func expansion(of node: AttributeSyntax, providingConformancesOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        [("VertexDescriptorProvider", nil)]
    }
}

// MARK: -

public struct VertexAttributeMacro {
}

extension VertexAttributeMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        print(#function)
        return []
    }
}

// MARK: -

@main
struct MetalSupportMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VertexDescriptorMacro.self,
        VertexAttributeMacro.self,
    ]
}

// MARK: -

struct VertexDescriptor {
    var attributes: [VertexAttribute]

    func source(name: String) -> [DeclSyntax] {
        var attributeDecls: [DeclSyntax] = []
        var offset = 0
        attributes.enumerated().forEach { index, attribute in
            attributeDecls += attribute.source(descriptorName: name, index: index, offset: offset)
            offset += attribute.size
        }

        return ["""
        static let descriptor: MTLVertexDescriptor {
            let \(raw:name) = MTLVertexDescriptor()
        """]
        + attributeDecls +
        ["""
        \(raw:name).layouts[0].stride = \(raw: offset)
            return \(raw:name)
        }
        """]
    }
}

struct VertexAttribute {
    var name: String
    var type: String
    var format: MTLVertexFormat
    var size: Int
    var bufferIndex: Int

    func macro() -> AttributeSyntax {
        return "@VertexAttribute(.\(raw: format), bufferIndex: \(raw: bufferIndex))"
    }

    func source(descriptorName: String, index: Int, offset: Int) -> [DeclSyntax] {
        return ["""
            // Attribute for ``\(raw: name)``: ``\(raw: type)``
            \(raw: descriptorName).attributes[\(raw: index)].format = \(raw: format)
            \(raw: descriptorName).attributes[\(raw: index)].offset = \(raw: offset)
            \(raw: descriptorName).attributes[\(raw: index)].bufferIndex = \(raw: bufferIndex)
        """]
    }
}

extension VertexAttribute {
    init(_ variableDecl: VariableDeclSyntax) throws {
        guard let binding = variableDecl.bindings.first else {
            throw MacroError.generic("No binding")
        }
        guard let name = binding.pattern.firstToken(viewMode: .sourceAccurate)?.text else {
            throw MacroError.generic("No identifier")
        }

        guard let type = binding.typeAnnotation?.type.description else {
            throw MacroError.generic("No type")
        }

        var format: MTLVertexFormat?
        var bufferIndex: Int = 0

        let vertexAttributeSyntax = variableDecl.attributes?.first(where: { element in
            guard let attributeSyntax = element.as(AttributeSyntax.self) else {
                return false
            }
            return ["VertexAttribute"].contains(attributeSyntax.attributeName.description)
        })
        if let vertexAttributeSyntax {
            guard let vertexAttributeSyntax = vertexAttributeSyntax.as(AttributeSyntax.self) else {
                fatalError()
            }
            if var elementIterator = vertexAttributeSyntax.argument?.as(TupleExprElementListSyntax.self)!.makeIterator() {
                if let element = elementIterator.next() {
                    if element.label?.description == "bufferIndex" {
                        bufferIndex = Int(element.expression.description)!
                    }
                    else {
                        switch element.expression.description {
                        case ".float2":
                            format = .float2
                        case ".float3":
                            format = .float3
                        case ".float4":
                            format = .float4
                        default:
                            fatalError()
                        }
                    }
                }
            }

            // TODO: Buffer index
        }

        if format == nil {
            switch type {
            case "SIMD2<Float>":
                format = .float2
            case "SIMD3<Float>":
                format = .float3
            case "SIMD4<Float>":
                format = .float4
            default:
                throw MacroError.generic("Unknown type")
            }
        }

        self.name = name
        self.type = type
        self.format = format!
        self.size = format!.size
        self.bufferIndex = bufferIndex
    }
}

extension MTLVertexFormat {
    var size: Int {
        switch self {
        case .float2:
            return 2 * MemoryLayout<Float>.stride // Do not use size of SIMD3<Float>
        case .float3:
            return 3 * MemoryLayout<Float>.stride // Do not use size of SIMD3<Float>
        case .float4:
            return 4 * MemoryLayout<Float>.stride // Do not use size of SIMD3<Float>
        default:
            fatalError()
        }
    }
}

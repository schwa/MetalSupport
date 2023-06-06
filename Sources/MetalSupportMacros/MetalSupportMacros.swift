import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum MacroError: Error {
    case generic(String)
}

public struct VertexDescriptorMacro {
}

extension VertexDescriptorMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.generic("Not a struct")
        }

        let attributes = try structDecl.memberBlock.members.compactMap { member -> VariableDeclSyntax? in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            return variableDecl
        }
        .enumerated()
        .map { index, variableDecl in
            guard let binding = variableDecl.bindings.first else {
                throw MacroError.generic("No binding")
            }
            guard let identifier = binding.pattern.firstToken(viewMode: .sourceAccurate)?.text else {
                throw MacroError.generic("No identifier")
            }
            guard let type = binding.typeAnnotation?.type.description else {
                throw MacroError.generic("No type")
            }
            return try vertexAttributeStanza(name: identifier, type: type, index: index, bufferIndex: 0)
        }
        return ["""
            static var _vertexDescriptor: MTLVertexDescriptor {
                let descriptor = MTLVertexDescriptor()
            \(raw: attributes.joined(separator: "\n"))
                descriptor.layouts[0].stride = -1
                return descriptor
            }
            """]
    }

    internal static func vertexAttributeStanza(name: String, type: String, index: Int, bufferIndex: Int) throws -> String {
        let format: String
        switch type {
        // TODO: this hard-coded string comparison is going to break oh so hard. Need a ``@VertexAttribute()`` macro too I suppose
        case "SIMD3<Float>":
            format = ".float3"
        case "SIMD4<Float>":
            format = ".float4"
        default:
            throw MacroError.generic("Unknown type \(type)")
        }
        let offset = -1
        return """
            // Attribute for ``\(name)``: ``\(type)``
            attributes[\(index)].format = \(format)
            attributes[\(index)].offset = \(offset)
            attributes[\(index)].bufferIndex = \(bufferIndex)
        """
    }
}

@main
struct VertexDescriptorMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VertexDescriptorMacro.self,
    ]
}

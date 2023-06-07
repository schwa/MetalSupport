import Metal
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

@main
struct MetalSupportMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VertexDescriptorMacro.self,
        VertexAttributeMacro.self,
    ]
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
        print("#####", Self.self, #function)
        return [("VertexDescriptorProvider", nil)]
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

struct VertexDescriptor {
    var attributes: [VertexAttribute]

    func source(name: String) -> [DeclSyntax] {
        var attributeDecls: [DeclSyntax] = []
        var offsets: [Int:Int] = [:]
        attributes.enumerated().forEach { index, attribute in
            attributeDecls += attribute.source(descriptorName: name, index: index, offset: offsets[attribute.bufferIndex, default: 0])
            offsets[attribute.bufferIndex, default: 0] += attribute.size
        }
        let offsetsDecl: [DeclSyntax] = offsets.sorted(by: { $0.key < $1.key }).map { bufferIndex, size in
            "\(raw:name).layouts[\(raw: bufferIndex)].stride = \(raw: size)"
        }
        return ["""
        static var vertexDescriptor: MTLVertexDescriptor {
            let \(raw:name) = MTLVertexDescriptor()
        """]
        + attributeDecls
        + offsetsDecl
        + ["""
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
            \(raw: descriptorName).attributes[\(raw: index)].format = \(raw: format.caseName)
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
                        format = MTLVertexFormat(caseName: element.expression.description)
                    }
                }
            }
        }

        if let format {

            if let expectedFormat = MTLVertexFormat(swiftType: type), expectedFormat != MTLVertexFormat(swiftType: type) {
                throw MacroError.generic("Mismatched types.")
            }
        }
        else {
            format = MTLVertexFormat(swiftType: type)
        }

        self.name = name
        self.type = type
        guard let format else {
            throw MacroError.generic("Could not infer vertex format.")
        }
        self.format = format
        self.size = format.size
        self.bufferIndex = bufferIndex
    }
}

extension MTLVertexFormat {

    init?(swiftType string: String) {
        switch string {
        case "SIMD2<Float>":
            self = .float2
        case "SIMD3<Float>":
            self = .float3
        case "SIMD4<Float>":
            self = .float4
        default:
            return nil
        }
    }

    init?(caseName string: String) {
        switch string {
        case ".float2":
            self = .float2
        case ".float3":
            self = .float3
        case ".float4":
            self = .float4
        default:
            return nil
        }
    }

    var caseName: String {
        switch self {
        case .float2:
            ".float2"
        case .float3:
            ".float3"
        case .float4:
            ".float4"
        default:
            fatalError()
        }
    }

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

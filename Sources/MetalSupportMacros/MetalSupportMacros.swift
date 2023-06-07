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
            context.diagnose(Diagnostic(node: declaration.as(Syntax.self)!, message: MetalSupportDiagnostic.generic("@\(node.attributeName) can only be applied to a struct")))
                return []
//            throw MacroError.generic("@\(node.attributeName) can only be applied to a struct")
        }
        let attributes = try structDecl.memberBlock.members.compactMap { member -> VertexAttribute? in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            return try VertexAttribute(variableDecl)
        }

        let bufferLayouts = try structDecl.memberBlock.members.compactMap { member -> VertexBufferLayout? in
            guard let macroExpansionDecl = member.decl.as(MacroExpansionDeclSyntax.self) else {
                return nil
            }
            guard macroExpansionDecl.macro.trimmedDescription == "VertexBufferLayout" else {
                return nil
            }
            guard let index = macroExpansionDecl.argumentList.element(labeled: "index") else {
                throw MacroError.generic("No index in VertexBufferLayout")
            }
            var bufferLayout = VertexBufferLayout(index: Int(index.trimmedDescription)!) // TODO: Bang
            if let stride = macroExpansionDecl.argumentList.element(labeled: "stride") {
                bufferLayout.stride = UInt(stride.trimmedDescription)! // TODO: Bang
            }
            if let stepFunction = macroExpansionDecl.argumentList.element(labeled: "stepFunction") {
                fatalError()
                bufferLayout.stepFunction = nil
            }
            if let stepRate = macroExpansionDecl.argumentList.element(labeled: "stepRate") {
                bufferLayout.stepRate = UInt(stepRate.trimmedDescription)! // TODO: Bang
            }
            return bufferLayout
        }
        let descriptor = VertexDescriptor(attributes: attributes, bufferLayouts: bufferLayouts)
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

public struct VertexBufferLayoutMacro {
}

extension VertexBufferLayoutMacro: DeclarationMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        // This implementation intentionally left blank.
        return []
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
    var bufferLayouts: [VertexBufferLayout]

    func source(name: String) -> [DeclSyntax] {
        var attributeDecls: [DeclSyntax] = []
        var offsets: [Int: Int] = [:]
        attributes.enumerated().forEach { index, attribute in
            attributeDecls += attribute.source(descriptorName: name, index: index, offset: offsets[attribute.bufferIndex, default: 0])
            offsets[attribute.bufferIndex, default: 0] += attribute.size
        }

        var bufferLayouts = Dictionary(uniqueKeysWithValues: bufferLayouts.map { ($0.index, $0) })
        for (index, stride) in offsets {
            if var bufferLayout = bufferLayouts[index] {
                if bufferLayout.stride == nil {
                    bufferLayout.stride = UInt(stride)
                    bufferLayouts[index] = bufferLayout
                }
            }
            else {
                bufferLayouts[index] = VertexBufferLayout(index: index, stride: UInt(stride)) // TODO: fix uint vs int
            }
        }

        let bufferLayoutDecls = bufferLayouts.values.sorted(by: { $0.index < $1.index }).flatMap { $0.source(descriptorName: name)}

        return ["""
        static var vertexDescriptor: MTLVertexDescriptor {
            let \(raw:name) = MTLVertexDescriptor()
        """]
        + attributeDecls
        + bufferLayoutDecls
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

extension VertexBufferLayout {
    func source(descriptorName: String) -> [DeclSyntax] {
        var result: [DeclSyntax] = [
            "\(raw: descriptorName).layouts[\(raw: index)].stride = \(raw: stride!)"
        ]
        if let stepFunction {
            result.append("\(raw: descriptorName).layouts[\(raw: index)].stepFunction = \(raw: stepFunction)")
        }
        if let stepRate {
            result.append("\(raw: descriptorName).layouts[\(raw: index)].stepRate = \(raw: stepRate)")
        }
        return result
    }
}

// MARK: -

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
            if let expectedFormat = MTLVertexFormat(swiftType: type), expectedFormat != format {
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

struct VertexBufferLayout {
    var index: Int
    var stride: UInt? = nil
    var stepFunction: MTLVertexStepFunction? = nil
    var stepRate: UInt? = nil
}

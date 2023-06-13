import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum InitError: CustomStringConvertible, Error {
    case onlyApplicableToStructOrClass

    var description: String {
        switch self {
        case .onlyApplicableToStructOrClass:
            return "@PublicInit can only be applied to an struct"
        }
    }
}

public struct InitMacro: MemberMacro {
    
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [SwiftSyntax.DeclSyntax]
    where
    Declaration : SwiftSyntax.DeclGroupSyntax,
    Context : SwiftSyntaxMacros.MacroExpansionContext {
        
        let isPublic = node.argument?.lastToken(viewMode: .sourceAccurate)?.text != false.description
        let membersDecl = try getMembers(declaration: declaration)
        
        let variablesName = membersDecl.compactMap { $0.bindings.first?.pattern }
        let variablesType = membersDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }
        
        let params = zip(variablesName, variablesType).map {
            "\($0): \($1)"
        }.joined(separator: ", ")
        
        let declInit = isPublic ? "public init" : "init"
        let initHeader = PartialSyntaxNodeString(stringLiteral: "\(declInit)(\(params))")
        
        let initializer = try InitializerDeclSyntax(initHeader) {
            for name in variablesName {
                ExprSyntax("self.\(name) = \(name)")
            }
        }
        return [DeclSyntax(initializer)]
    }
    
    private static func getMembers<Declaration : DeclGroupSyntax>(declaration: Declaration) throws -> [VariableDeclSyntax] {
        let members = try {
            if let structDecl = declaration.as(StructDeclSyntax.self) {
                return structDecl.memberBlock.members
            } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
                return classDecl.memberBlock.members
            } else {
                throw InitError.onlyApplicableToStructOrClass
            }
        }()

        return members.compactMap { $0.decl.as(VariableDeclSyntax.self)}
    }
}

@main
struct DGPMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InitMacro.self
    ]
}


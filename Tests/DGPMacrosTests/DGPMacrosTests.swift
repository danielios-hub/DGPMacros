import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import DGPMacrosMacros

let testMacros: [String: Macro.Type] = [
    "Init": InitMacro.self
]

final class DGPMacrosTests: XCTestCase {
    
    func testPublicInitMacro() {
        let isPublic = true
        let isStruct = true
        assertMacroExpansion(
            getSource(isPublic: isPublic, isStruct: isStruct),
            expandedSource: getExpanded(isPublic: isPublic, isStruct: isStruct),
            macros: testMacros
        )
    }
    
    func testInternalInitMacro() {
        let isPublic = false
        let isStruct = true
        assertMacroExpansion(
            getSource(isPublic: isPublic, isStruct: isStruct),
            expandedSource: getExpanded(isPublic: isPublic, isStruct: isStruct),
            macros: testMacros
        )
    }
    
    func testClassPublicInitMacro() {
        let isPublic = true
        let isStruct = false
        assertMacroExpansion(
            getSource(isPublic: isPublic, isStruct: isStruct),
            expandedSource: getExpanded(isPublic: isPublic, isStruct: isStruct),
            macros: testMacros
        )
    }
    
    func testClassInternalInitMacro() {
        assertMacroExpansion(
            getSource(isPublic: false, isStruct: false),
            expandedSource: getExpanded(isPublic: false, isStruct: false),
            macros: testMacros
        )
    }
    
    func testDefaultInitMacro() {
        let isPublic: Bool? = nil
        let isStruct = true
        assertMacroExpansion(
            getSource(isPublic: isPublic, isStruct: isStruct),
            expandedSource: getExpanded(isPublic: true, isStruct: isStruct),
            macros: testMacros
        )
    }
    
    private func getSource(isPublic: Bool?, isStruct: Bool) -> String {
        let header = {
            switch isPublic {
            case let .some(state):
                return "@Init(isPublic: \(state.description)"
                
            case .none:
                return "@Init"
            }
        }()
        
        return """
        \(header)
        \(isStruct ? "struct" : "class") Person {
            let name: String
            let age: Int
            var gender: String
            let accounts: [String]
        }
        """
    }
    
    private func getExpanded(isPublic: Bool?, isStruct: Bool) -> String {
        let initDecl = isPublic != false ? "public init" : "init"
        return """
        
        \(isStruct ? "struct" : "class") Person {
            let name: String
            let age: Int
            var gender: String
            let accounts: [String]
            \(initDecl)(name: String, age: Int, gender: String, accounts: [String]) {
                self.name = name
                self.age = age
                self.gender = gender
                self.accounts = accounts
            }
        }
        """
    }
}

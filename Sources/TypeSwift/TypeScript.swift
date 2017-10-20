//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

public enum TypeScript: TypeScriptInitializable, SwiftStringConvertible {

    //case conformingModel(AccessLevel?, ModelDeclaration, String, String/*protocol conformation*/, ModelBody)
    case empty
    case element(TypeScriptElement)
    indirect case module(String, TypeScript)
    indirect case namespace(String, TypeScript)
    indirect case composed(TypeScript, TypeScript)
    
    public var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .element(let element):
            return element.swiftValue
        case .module(let name, let typeScript):
            return "enum \(name) {\n\(typeScript.swiftValue)\n}"
        case .namespace(let name, let typeScript):
            return "enum \(name) {\n\(typeScript.swiftValue)\n}"
        case .composed(let type1, let type2):
            return "\(type1.swiftValue)\n\(type2.swiftValue)"
                .trimTrailingCharacters(in: .newlines)
                .trimLeadingCharacters(in: .newlines)
        }
    }
    
    public init(typescript: String) throws {
        let working = typescript
            .trimLeadingWhitespace()
            .trimTrailingWhitespace()
            .trimComments()
            .trimImport()
            .trimConstructor()

        var typescript1: TypeScript!
        var elementRange: Range<String.Index>!

        let bodyRange: Range<String.Index>? = working.rangeOfBody()
        
        if working.hasPrefix(.namespace) {
            elementRange = bodyRange!
            let body = String(working[elementRange])
            guard let namespace = working.suffix(fromInt: working.namespaceDeclarationPrefix()!.count)
                .getWord(atIndex: 0, seperation: .whitespaces) else {

                let err = TypeScriptError.cannotDeclareNamespaceWithoutBody
                err.log()
                throw err
            }

            if body.count <= "{ }".count {
                typescript1 = .namespace(namespace, .empty)
            } else {
                let inner = String(body[body.index(after: body.startIndex)..<body.index(before: body.endIndex)])
                typescript1 = .namespace(namespace, try TypeScript(typescript: inner))
            }
        } else if working.hasPrefix(.module) {
            elementRange = bodyRange!
            let body = String(working[elementRange])
            guard let module = String(working.suffix(from: working.index(working.startIndex,
                                                                      offsetBy: working.moduleDeclarationPrefix()!.count)))
                .getWord(atIndex: 0, seperation: .whitespaces) else {
                let err = TypeScriptError.cannotDeclareModuleWithoutBody
                err.log()
                throw err
            }

            if body.count <= "{ }".count {
                typescript1 = .namespace(module, .empty)
            } else {
                let inner = String(body[body.index(after: body.startIndex)..<body.index(before: body.endIndex)])
                typescript1 = .module(module, try TypeScript(typescript: inner))
            }
        } else {
            let element = try TypeScriptElement(typescript: working)
            typescript1 = .element(element)
            switch element {
            case .function:
                elementRange = working.rangeOfFunction()
            case .interface,
                 .model:
                elementRange = working.rangeOfBody()
            case .`typealias`:
                elementRange = working.startIndex..<working.endOfExpressionIndex
            }
        }

        var nextTypeScript = ""
        if working.endIndex > elementRange.upperBound {
            let nextTypeScriptStart = working.index(after: elementRange.upperBound)
            nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                .trimLeadingCharacters(in: .whitespacesAndNewlines)
        }

        let typescript2 = (try? TypeScript(typescript: nextTypeScript)) ?? .empty
        self = .composed(typescript1, typescript2)
    }
}

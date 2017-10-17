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
    case `typealias`(String, Type)
    case function(Function)
    case model(Model)
    case interface(Interface)
    indirect case module(String, TypeScript)
    indirect case namespace(String, TypeScript)
    indirect case composed(TypeScript, TypeScript)
    
    public var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .`typealias`(let name, let type):
            return "typealias \(name) = \(type.swiftValue)"
        case .function(let function):
            return function.swiftValue
        case .interface(let interface):
            return interface.swiftValue
        case .model(let model):
            return model.swiftValue
        case .module(let name, let typeScript):
            return "struct \(name) {\n\(typeScript.swiftValue)\n}"
        case .namespace(let name, let typeScript):
            return "struct \(name) {\n\(typeScript.swiftValue)\n}"
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

        var typescript1: TypeScript!
        var elementRange: Range<String.Index>!
        if working.hasPrefix(.`import`){
            typescript1 = .empty
            let upper = working.rangeOfCharacter(from: CharacterSet(charactersIn: ";\n"))?.upperBound ?? working.endIndex
            elementRange = working.startIndex..<upper
        } else if working.hasPrefix(.functionDeclaration) {
            guard let start = working.rangeOfFunction()?.lowerBound,
                let end = working.rangeOfBody()?.upperBound else {
                throw TypeScriptError.invalidFunctionDeclaration
            }
            elementRange = start..<end
            typescript1 = .function(try Function(typescript: String(working[elementRange])))
        } else if working.hasPrefix(.typeAlias) {

            let typealiasKeyword = working.typealiasDeclarationPrefix()!

            if let endIndex = working.index(of: "\n") ?? working.index(of: ";") {
                elementRange = working.startIndex..<endIndex
            } else {
                elementRange = working.startIndex..<working.endIndex
            }

            let suffix = String(working.suffix(from: working.index(working.startIndex, offsetBy: typealiasKeyword.count)))
            let components = suffix.components(separatedBy: "=")
                .map {
                    return $0.trimLeadingWhitespace()
                        .trimTrailingWhitespace()
                }
            let nameRaw = components[0]
            guard let typeRaw = components[1].trimLeadingWhitespace()
                .getWord(atIndex: 0, seperation: CharacterSet(charactersIn: "\n;")) else {
                throw TypeScriptError.invalidTypealias
            }
            typescript1 = TypeScript.`typealias`(nameRaw, try Type(typescript: typeRaw))

        } else if let bodyRange = working.rangeOfBody() {
            elementRange = bodyRange
            let raw = String(working[working.startIndex..<bodyRange.upperBound])
            let body = String(working[bodyRange])

            if working.hasPrefix(.interface) {

                let interface = try Interface(typescript: raw)

                typescript1 = .interface(interface)

            } else if working.hasPrefix(.model) {
                let model = try Model(typescript: raw)
                typescript1 = .model(model)
            } else if working.hasPrefix(.namespace) {
                guard let namespace = String(working.suffix(from: working.index(working.startIndex,
                                                                          offsetBy: working.namespaceDeclarationPrefix()!.count)))
                    .getWord(atIndex: 0, seperation: .whitespaces) else {

                    throw TypeScriptError.cannotDeclareNamespaceWithoutBody
                }

                if body.count <= "{ }".count {
                    typescript1 = .namespace(namespace, .empty)
                } else {
                    let inner = String(body[body.index(after: body.startIndex)..<body.index(before: body.endIndex)])
                    typescript1 = .namespace(namespace, try TypeScript(typescript: inner))
                }
            } else if working.hasPrefix(.module) {
                guard let module = String(working.suffix(from: working.index(working.startIndex,
                                                                          offsetBy: working.moduleDeclarationPrefix()!.count)))
                    .getWord(atIndex: 0, seperation: .whitespaces) else {
                    throw TypeScriptError.cannotDeclareModuleWithoutBody
                }

                if body.count <= "{ }".count {
                    typescript1 = .namespace(module, .empty)
                } else {
                    let inner = String(body[body.index(after: body.startIndex)..<body.index(before: body.endIndex)])
                    typescript1 = .module(module, try TypeScript(typescript: inner))
                }
            }
        }  else {
            throw TypeScriptError.unsupportedTypeScript(typescript)
        }

        var nextTypeScript = ""
        if working.endIndex > elementRange.upperBound {
            let nextTypeScriptStart = working.index(after: elementRange.upperBound)
            nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                .trimLeadingCharacters(in: .whitespacesAndNewlines)
        }

        if ((try? TypeScript(typescript: nextTypeScript)) ?? nil) != nil {
            let typescript2 = try TypeScript(typescript: nextTypeScript)
            self = .composed(typescript1, typescript2)
        } else if typescript1 != nil {
            self = typescript1
        } else {
            if let index = working.index(of: "\n") ?? working.index(of: ";") {
                let working = String(working[working.startIndex..<index])
                throw TypeScriptError.unsupportedTypeScript(working)
            } else {
                throw TypeScriptError.unsupportedTypeScript(working)
            }
        }
    }
}

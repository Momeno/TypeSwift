//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum TypeScript: TypeScriptInitializable, SwiftStringConvertible {

    //case conformingModel(AccessLevel?, ModelDeclaration, String, String/*protocol conformation*/, ModelBody)
    case empty
    case `typealias`(String, Type)
    case model(Model)
    case interface(Interface)
    indirect case module(String, TypeScript)
    indirect case namespace(String, TypeScript)
    indirect case composed(TypeScript, TypeScript)
    
    var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .`typealias`(let name, let type):
            return "typealias \(name) = \(type.swiftValue)"
        case .interface(let interface):
            return interface.swiftValue
        case .model(let model):
            return model.swiftValue
        case .module(let name, let typeScript):
            return "struct \(name) {\n\(typeScript.swiftValue)\n}"
        case .namespace(let name, let typeScript):
            return "struct \(name) {\n\(typeScript.swiftValue)\n}"
        case .composed(let type1, let type2):
            return "\(type1.swiftValue)\n\n\(type2.swiftValue)"
                .trimTrailingCharacters(in: .newlines)
                .trimLeadingCharacters(in: .newlines)
        }
    }
    
    init(typescript: String) throws {
        let working = typescript
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)

        var typescript1: TypeScript!
        var elementRange: Range<String.Index>!

        if let bodyRange = working.rangeOfBody() {
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
        }  else if working.hasPrefix(.`typealias`) {

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
            guard let typeRaw = components[1].getWord(atIndex: 0, seperation: .whitespaces) else {
                throw TypeScriptError.invalidTypealias
            }
            typescript1 = TypeScript.`typealias`(nameRaw, try Type(typescript: typeRaw))

        } else {
            throw TypeScriptError.unsupportedTypeScript(typescript)
        }

        var nextTypeScript = ""
        if working.endIndex > elementRange.upperBound {
            let nextTypeScriptStart = working.index(after: elementRange.upperBound)
            nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                .trimLeadingCharacters(in: .whitespacesAndNewlines)
        }

        if (nextTypeScript.hasPrefix(.interface) ||
            nextTypeScript.hasPrefix(.model)) {

            let typescript2 = try TypeScript(typescript: nextTypeScript)
            self = .composed(typescript1, typescript2)
        } else {
            self = typescript1
        }
    }
}

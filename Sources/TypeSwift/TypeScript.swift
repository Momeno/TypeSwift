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
    case model(Model)
    case interface(Interface)
    indirect case module(String, TypeScript)
    indirect case namespace(String, TypeScript)
    indirect case composed(TypeScript, TypeScript)
    
    var swiftValue: String {
        switch self {
        case .empty:
            return ""
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
        
        guard let bodyRange = working.rangeOfBody() else {
            guard working.trimLeadingWhitespace().trimTrailingWhitespace().isEmpty else {
                throw TypeScriptError.typeScriptEmpty
            }
            self = .empty
            return
        }

        let raw = String(working[working.startIndex..<bodyRange.upperBound])
        let body = String(working[bodyRange])

        var typescript1: TypeScript!

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
        } else {
            throw TypeScriptError.unsupportedTypeScript(typescript)
        }

        var nextTypeScript = ""
        if working.endIndex > bodyRange.upperBound {
            let nextTypeScriptStart = working.index(after: bodyRange.upperBound)
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

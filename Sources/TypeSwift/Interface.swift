//
//  Interface.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct Interface: TypeScriptInitializable, SwiftStringConvertible {

    let interfaceDec: InterfaceDeclaration
    let name: String
    let body: InterfaceBody

    var swiftValue: String {
        return "\(interfaceDec.swiftValue) \(name) \(body.swiftValue)"
    }

    init(typescript: String) throws {
        let working = typescript
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)

        guard let bodyRange = working.rangeOfBody() else {
            throw TypeScriptError.cannotDeclareInterfaceWithoutBody
        }

        let body = try InterfaceBody(typescript: String(working[bodyRange]))

        guard let interfaceDec = working.interfaceDeclarationPrefix() else {
            throw TypeScriptError.invalidDeclaration(String(working.prefix(upTo: bodyRange.upperBound)))
        }

        let offsetedIndex = working.index(working.startIndex, offsetBy: interfaceDec.rawValue.count)
        let suffix = String(working.suffix(from: offsetedIndex))

        guard let indexOfSpace = suffix.index(of: " ") else {
            throw TypeScriptError.invalidDeclaration(String(suffix.prefix(upTo: bodyRange.upperBound)))
        }

        guard let name = String(suffix.suffix(from: indexOfSpace))
            .getWord(atIndex: 0, seperation: .whitespaces) else {
                throw TypeScriptError.invalidDeclaration(String(suffix.prefix(upTo: bodyRange.upperBound)))
        }

        self.interfaceDec = interfaceDec
        self.name = name
        self.body = body
    }
}

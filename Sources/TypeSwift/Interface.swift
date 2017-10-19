//
//  Interface.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

public struct Interface: TypeScriptInitializable, SwiftStringConvertible {

    let interfaceDec: InterfaceDeclaration
    let name: String
    let body: InterfaceBody
    let extends: [String]?

    public var swiftValue: String {
        var extendsStr = ""
        if let extends = self.extends {
            extendsStr = ": " + extends.joined(separator: ", ")
                .trimTrailingWhitespace()
                .trimLeadingWhitespace()
        }
        return "\(interfaceDec.swiftValue) \(name)\(extendsStr) \(body.swiftValue)"
    }

    public init(typescript: String) throws {
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

        let brace = suffix.index(of: "{")!
        if let extends = suffix.prefix(upTo: brace)
            .range(of: "extends") {

            let tmp = String(suffix.suffix(from: extends.upperBound))
            let end = tmp.range(of: "implements")?.lowerBound ?? tmp.index(of: "{")!
            let sfx = String(tmp.prefix(upTo: end))

            self.extends = sfx.componentsWithoutPadding(separatedBy: ",")

        } else { self.extends = nil }

        self.interfaceDec = interfaceDec
        self.name = name
        self.body = body
    }
}

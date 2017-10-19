//
//  Model.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

public struct Model: TypeScriptInitializable, SwiftStringConvertible {
    let modelDec: ModelDeclaration
    let name: String
    let extends: [String]?
    let implements: [String]?
    let body: ModelBody

    public var swiftValue: String {

        var extends = ""
        switch (self.extends, self.implements) {
        case (.some, .some):
            extends = ": \(self.extends!.joined(separator: ", ")), \(self.implements!.joined(separator: ", "))"
        case (.some, .none):
            extends = ": \(self.extends!.joined(separator: ", "))"
        case (.none, .some):
            extends = ": \(self.implements!.joined(separator: ", "))"
        case (.none, .none):
            break
        }

        return "\(modelDec.swiftValue) \(name)\(extends) \(body.swiftValue)"
    }

    public init(typescript: String) throws {
        let working = typescript
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)

        guard let bodyRange = working.rangeOfBody() else {
            throw TypeScriptError.cannotDeclareModelWithoutBody
        }

        let body = try ModelBody(typescript: String(working[bodyRange]))

        guard let modelDec = working.modelDeclarationPrefix() else {
            throw TypeScriptError.invalidDeclaration(String(working.prefix(upTo: bodyRange.upperBound)))
        }
        
        let offsetedIndex = working.index(working.startIndex, offsetBy: modelDec.rawValue.count)
        let suffix = String(working.suffix(from: offsetedIndex))
        guard let indexOfSpace = suffix.index(of: " ") else {
           throw TypeScriptError.invalidDeclaration(String(typescript.prefix(upTo: bodyRange.upperBound)))
        }
        
        guard let name = String(suffix.suffix(from: indexOfSpace))
            .getWord(atIndex: 0, seperation: .whitespaces) else {
            throw TypeScriptError.invalidDeclaration(String(typescript.prefix(upTo: bodyRange.upperBound)))
        }

        let brace = suffix.index(of: "{")!
        if let extends = suffix.prefix(upTo: brace)
            .range(of: "extends") {

            let tmp = String(suffix.suffix(from: extends.upperBound))
            let end = tmp.range(of: "implements")?.lowerBound ?? tmp.index(of: "{")!
            let sfx = String(tmp.prefix(upTo: end))

            self.extends = sfx.components(separatedBy: ",")
                .map { $0.trimTrailingWhitespace().trimLeadingWhitespace() }
                .filter { $0.isEmpty == false }
        } else { self.extends = nil }

        if let implements = suffix.prefix(upTo: brace)
            .range(of: "implements") {
            let tmp = String(suffix.suffix(from: implements.upperBound))
            let sfx = String(tmp.prefix(upTo: tmp.index(of: "{")!))

            self.implements = sfx.components(separatedBy: ",")
                .map { $0.trimTrailingWhitespace().trimLeadingWhitespace() }
                .filter { $0.isEmpty == false }
        } else { self.implements = nil }

        self.modelDec = modelDec
        self.name = name
        self.body = body
    }
}

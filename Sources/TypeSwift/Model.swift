//
//  Model.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct Model: TypeScriptInitializable, SwiftStringConvertible {
    let modelDec: ModelDeclaration
    let name: String
    let extends: String?
    let implements: String?
    let body: ModelBody

    var swiftValue: String {

        var extends = ""
        switch (self.extends, self.implements) {
        case (.some, .some):
            extends = ": \(self.extends!), \(self.implements!)"
        case (.some, .none):
            extends = ": \(self.extends!)"
        case (.none, .some):
            extends = ": \(self.implements!)"
        case (.none, .none):
            break
        }

        return "\(modelDec.swiftValue) \(name)\(extends) \(body.swiftValue)"
    }

    init(typescript: String) throws {
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
            let sfx = String(suffix.suffix(from: suffix.index(after: extends.upperBound)))

            self.extends = sfx.getWord(atIndex: 0, seperation: .whitespaces)
        } else { self.extends = nil }

        if let implements = suffix.prefix(upTo: brace)
            .range(of: "implements") {
            let sfx = String(suffix.suffix(from: suffix.index(after: implements.upperBound)))
            self.implements = sfx.getWord(atIndex: 0, seperation: .whitespaces)
        } else { self.implements = nil }

        self.modelDec = modelDec
        self.name = name
        self.body = body
    }
}

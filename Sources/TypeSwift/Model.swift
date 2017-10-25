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
    let associatedTypesString: String?
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
        let genericString = self.associatedTypesString != nil ? "<\(self.associatedTypesString!)>" : ""
        return "\(modelDec.swiftValue) \(name)\(genericString)\(extends) \(body.swiftValue)"
    }

    public init(typescript: String) throws {
        let working = typescript
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)

        guard let bodyRange = working.rangeOfBody() else {
            let err = TypeScriptError.cannotDeclareModelWithoutBody
            err.log()
            throw err
        }

        let body = try ModelBody(typescript: String(working[bodyRange]))

        guard let modelDec = working.modelDeclarationPrefix() else {
            let err = TypeScriptError.invalidDeclaration(String(working.prefix(upTo: bodyRange.upperBound)))
            err.log()
            throw err
        }
        
        let offsetedIndex = working.index(working.startIndex, offsetBy: modelDec.rawValue.count)
        var suffix = String(working.suffix(from: offsetedIndex))
            .trimLeadingWhitespace()
        
        var nameOptional: String?
        var associatedTypesString: String?

        if let rangeOfGenerics = suffix.range(of: "<(.*|\\n)>",
                                              options: .regularExpression,
                                              range: suffix.startIndex..<bodyRange.lowerBound,
                                              locale: nil) {
            
            // get the "..." in <...>
            let innerRange = suffix.index(after: rangeOfGenerics.lowerBound)..<suffix.index(before: rangeOfGenerics.upperBound)
            associatedTypesString = String(suffix[innerRange])
            
            nameOptional = String(suffix.prefix(upTo: rangeOfGenerics.lowerBound))
                .trimTrailingWhitespace()
            suffix = suffix.suffix(fromIndex: rangeOfGenerics.upperBound)

        } else {
            nameOptional = suffix.getWord(atIndex: 0, seperation: .whitespaces)
        }
        
        guard let name = nameOptional else {
            let err = TypeScriptError.invalidDeclaration(String(typescript.prefix(upTo: bodyRange.upperBound)))
            err.log()
            throw err
        }

        let brace = suffix.index(of: "{")!
        if let extends = suffix.prefix(upTo: brace)
            .range(of: "extends") {

            let tmp = suffix.suffix(fromIndex: extends.upperBound)
            let end = tmp.range(of: "implements")?.lowerBound ?? tmp.index(of: "{")!
            let sfx = String(tmp.prefix(upTo: end))

            self.extends = sfx.componentsWithoutPadding(separatedBy: ",")

        } else { self.extends = nil }

        if let implements = suffix.prefix(upTo: brace)
            .range(of: "implements") {
            let tmp = suffix.suffix(fromIndex: implements.upperBound)
            let sfx = String(tmp.prefix(upTo: tmp.index(of: "{")!))

            self.implements = sfx.componentsWithoutPadding(separatedBy: ",")

        } else { self.implements = nil }

        self.modelDec = modelDec
        self.name = name
        self.associatedTypesString = associatedTypesString
        self.body = body
    }
}

//
//  Model.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct Model: RawRepresentable, SwiftStringConvertible {
    let modelDec: ModelDeclaration
    let name: String
    let extends: String?
    let implements: String?
    let body: ModelBody
    let rawValue: String
    
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

    init?(rawValue: String) {
        let working = rawValue
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)

        guard let bodyRange = working.rangeOfBody() else {
            return nil
        }
        guard let body = ModelBody(rawValue: String(working[bodyRange])) else {
            return nil
        }
        guard let modelDec = working.modelDeclarationPrefix() else {
            return nil
        }
        
        let offsetedIndex = working.index(working.startIndex, offsetBy: modelDec.rawValue.count)
        let suffix = String(working.suffix(from: offsetedIndex))
        guard let indexOfSpace = suffix.index(of: " ") else {
            return nil
        }
        
        guard let name = String(suffix.suffix(from: indexOfSpace))
            .getWord(atIndex: 0, seperation: .whitespaces) else {
                return nil
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
        self.rawValue = rawValue
    }
}

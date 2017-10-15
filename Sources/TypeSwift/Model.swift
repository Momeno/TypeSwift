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
    let protocolConformance: String?
    let body: ModelBody
    let rawValue: String
    
    var swiftValue: String {
        return "\(modelDec.swiftValue) \(name)\(protocolConformance != nil ? ": " + protocolConformance! : "") \(body.swiftValue)"
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
        
        guard var name = String(suffix.suffix(from: indexOfSpace))
            .getWord(atIndex: 0, seperation: .whitespaces) else {
                return nil
        }
        
        if let colonIdx = suffix.index(of: ":"), colonIdx < bodyRange.lowerBound {
            name = name.replacingOccurrences(of: ":", with: "")

            let protocolContainer = String(suffix.suffix(from: suffix.index(after: colonIdx)))
                .trimLeadingWhitespace()
            let brace = protocolContainer.index(of: "{")!
            self.protocolConformance = String(protocolContainer.prefix(upTo: brace))
                .trimLeadingWhitespace()
                .trimTrailingWhitespace()
        } else {
            self.protocolConformance = nil
        }

        self.modelDec = modelDec
        self.name = name
        self.body = body
        self.rawValue = rawValue
    }
}

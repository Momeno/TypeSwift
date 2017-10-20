//
//  PropertyDefinition.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

public enum PropertyDefinition: TypeScriptInitializable, SwiftStringConvertible {
    case optional(String, Type?)
    case definite(String, Type?, Expression?)
    
    public var swiftValue: String {
        switch self {
        case .definite(let name, let type, let assignment):
            return "\(name)\(type?.swiftValue != nil ? ": \(type?.swiftValue ?? "Any")" : "")\(assignment != nil ? " = \(assignment!.swiftValue)" : "")"
        case .optional(let name, let type):
            return "\(name)\(type?.swiftValue != nil ? ": \(type?.swiftValue ?? "Any")" : "")?"
        }
    }

    public init(typescript: String) throws {
        guard let first = typescript.first else {
            let err = TypeScriptError.invalidDeclaration(typescript)
            err.log()
            throw err
        }

        guard first != "[" else {
            // index signature
            let msg = "[ at the start of a property declaration is a sign of an Index Signature, which is not supported"
            fatalError(msg)
        }

        let splitIndex = typescript.index(of: ":")
        let equalsIndex = typescript.index(of: "=")
        let definesType =  splitIndex != nil && (equalsIndex != nil ? splitIndex ?? typescript.endIndex < equalsIndex! : true)
        let definesValue = equalsIndex != nil

        var typeRaw: String?
        var assignment: String?
        if definesValue {
            assignment = String(typescript.suffix(from: typescript.index(after: equalsIndex!)))
                .trimLeadingWhitespace()
                .trimTrailingWhitespace()
        }

        if definesType {
            if definesValue {
                typeRaw = String(typescript[typescript.index(after: splitIndex!)..<equalsIndex!])
                    .trimmingCharacters(in: .whitespaces)
            } else {
                typeRaw = String(typescript.suffix(from: typescript.index(after: splitIndex!)))
                    .trimmingCharacters(in: .whitespaces)
            }
        }

        let nameEndIndex = definesType ? splitIndex! : equalsIndex ?? typescript.endIndex
        var name = String(typescript.prefix(upTo: nameEndIndex))
            .trimTrailingWhitespace()
            .trimLeadingWhitespace()

        var isOptional = false

        if name.hasSuffix("?") {
            isOptional = true
            name = String(name[name.startIndex..<name.index(before: name.endIndex)])
        }

        guard (definesValue || definesType) || (name.index(of: " ") == nil) else {
            let err = TypeScriptError.invalidDeclaration(typescript)
            err.log()
            throw err
        }

        let type: Type? = definesType ? try Type(typescript: typeRaw!) : nil
        let expr: Expression? = definesValue ? try Expression(typescript: assignment!) : nil

        if isOptional {
            self = .optional(name, type)
        } else {
            self = .definite(name, type, expr)
        }

    }
}

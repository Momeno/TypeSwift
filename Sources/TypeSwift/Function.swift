//
//  Function.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 17/10/2017.
//

import Foundation

public enum Function: TypeScriptInitializable, SwiftStringConvertible {

    case empty
    case function(PropertyAccessLevel, PropertyScope?, FunctionDeclaration, CodeBlock)


    public var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .function(let access, let scope, let declaration, let body):
            let addition = "\(access.swiftValue)\(scope != nil ? " \(scope!.swiftValue)" : "")"

            return "\(addition) \(declaration.swiftValue) \(body.swiftValue)"
                .replacingOccurrences(of: "  ", with: " ")
        }
    }

    public init(typescript: String) throws {
        var working = typescript
            .trimTrailingWhitespace()
            .trimLeadingWhitespace()

        var scope: PropertyScope?
        var access = PropertyAccessLevel.`public`

        guard var first = working.getWord(atIndex: 0, seperation: .whitespaces) else {
            self = .empty
            return
        }

        if let sp = PropertyScope(rawValue: first) {
            scope = sp
            working = String(working.suffix(from: working.index(working.startIndex, offsetBy: first.count)))
                .trimLeadingWhitespace()
            guard let word = working.getWord(atIndex: 0, seperation: .whitespaces) else {
                self = .empty
                return
            }
            first = word
        }

        if let acc = PropertyAccessLevel(rawValue: working) {
            access = acc
            working = String(working.suffix(from: working.index(working.startIndex, offsetBy: first.count)))
                .trimLeadingWhitespace()
        }

        guard let body = working.rangeOfBody() else {
            throw TypeScriptError.invalidDeclaration(typescript)
        }

        let constructorRegex = "constructor\\s*\\("
        let isConstructor = working.range(of: constructorRegex,
                                             options: .regularExpression,
                                             range: nil,
                                             locale: nil) != nil
        if isConstructor {
            self = .empty
        } else {
            self = .function(access, scope, try FunctionDeclaration(typescript: String(working[working.startIndex..<body.lowerBound])),
                             try CodeBlock(typescript: String(working[body])))
        }

    }
}

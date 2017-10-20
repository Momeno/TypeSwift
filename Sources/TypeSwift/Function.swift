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

        if let acc = PropertyAccessLevel.extractWithPrefix(from: working) {
            access = acc.value
            working = working.suffix(fromIndex: working.index(atInt: acc.count))
                .trimLeadingWhitespace()
        }

        if let sp = PropertyScope.extractWithPrefix(from: working) {
            scope = sp.value
            working = working.suffix(fromIndex: working.index(atInt: sp.count))
                .trimLeadingWhitespace()
        }

        guard let body = working.rangeOfBody() else {
            let err = TypeScriptError.invalidDeclaration(typescript)
            err.log()
            throw err
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

//
//  CodeBlock.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur on 17/10/2017.
//

import Foundation

public enum CodeBlock: TypeScriptInitializable, SwiftStringConvertible {

    case empty
    case expressions([Expression])

    public var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .expressions(let exprs):
            let expressions = exprs.map { $0.swiftValue }
                .filter { $0.isEmpty == false }
                .joined(separator: "\n")
            return "{\n\(expressions)\n}"
        }
    }

    public init(typescript: String) throws {

        guard typescript.count > "{ }".count,
            let startOfExpressions = typescript.rangeOfCharacter(from: CharacterSet(charactersIn: "{") )?.upperBound else {
            self = .empty
            return
        }

        let innerRange = startOfExpressions..<typescript.index(before: typescript.endIndex)
        let innerString = String(typescript[innerRange])

        let expressionEndingSet = CharacterSet(charactersIn: "\n;")
        let expressions = try innerString.componentsWithoutPadding(separatedBy: expressionEndingSet)
            .flatMap(Expression.init(typescript:))

        self = .expressions(expressions)

    }
}

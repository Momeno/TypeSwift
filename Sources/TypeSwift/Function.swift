//
//  Function.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 17/10/2017.
//

import Foundation

public enum Function: TypeScriptInitializable, SwiftStringConvertible {

    case empty
    case function(FunctionDeclaration, CodeBlock)

    public var swiftValue: String {
        switch self {
        case .empty:
            return ""
        case .function(let declaration, let body):
            return "\(declaration.swiftValue) \(body.swiftValue)"
                .replacingOccurrences(of: "  ", with: " ")
        }
    }

    public init(typescript: String) throws {
        guard let body = typescript.rangeOfBody() else {
            throw TypeScriptError.invalidDeclaration(typescript)
        }

        let constructorRegex = "constructor\\s*\\("
        let isConstructor = typescript.range(of: constructorRegex,
                                             options: .regularExpression,
                                             range: nil,
                                             locale: nil) != nil
        if isConstructor {
            self = .empty
        } else {
            self = .function(try FunctionDeclaration(typescript: String(typescript[typescript.startIndex..<body.lowerBound])),
                             try CodeBlock(typescript: String(typescript[body])))
        }

    }
}

//
//  Function.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 17/10/2017.
//

import Foundation

public struct Function: TypeScriptInitializable, SwiftStringConvertible {
    
    let declaration: FunctionDeclaration
    let body: CodeBlock

    public var swiftValue: String {
        return "\(declaration.swiftValue) \(body.swiftValue)"
            .replacingOccurrences(of: "  ", with: " ")
    }

    public init(typescript: String) throws {
        guard let body = typescript.rangeOfBody() else {
            throw TypeScriptError.invalidDeclaration(typescript)
        }
        self.declaration = try FunctionDeclaration(typescript: String(typescript[typescript.startIndex..<body.lowerBound]))
        self.body = try CodeBlock(typescript: String(typescript[body]))
    }
}

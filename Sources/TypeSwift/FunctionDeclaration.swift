//
//  FunctionDeclaration.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur on 17/10/2017.
//

import Foundation

public struct FunctionDeclaration: SwiftStringConvertible, TypeScriptInitializable {

    let typescript: String
    let functionParams: [PropertyDefinition]

    public var swiftValue: String {
        var str = self.typescript.trimLeadingWhitespace()

        let function = "function"

        var prefix = ""
        if let range = self.typescript.range(of: function) {
            str = str.replacingCharacters(in: range, with: "func")
        } else {
            prefix = "func "
        }

        let regex = "\\(.*\\)"
        let paramStr = functionParams
            .map {
                "_ \($0.swiftValue)"
            }
            .joined(separator: ", ")

        let paramString = "(\(paramStr))"
        if let range = str.range(of: regex,
                                 options: .regularExpression,
                                 range: nil,
                                 locale: nil) {
            str = str.replacingCharacters(in: range, with: paramString)
        }

        let colon = ":"
        let returnIndicator = "->"

        // swap colon with returnIndicator except inside brackets or quotes
        str = str.swapInstances(of: colon, with: returnIndicator, exceptInside: "\\([^\\)]*\\)|(\(String.quoteRegex))")

        if let rangeOfReturnIndicator = str.range(of: returnIndicator, options: .backwards, range: nil, locale: nil) {
            let returnType = str.suffix(fromIndex: rangeOfReturnIndicator.upperBound)
                .trimLeadingWhitespace()
                .trimTrailingWhitespace()

            if let returnTypeRange = str.range(of: returnType, options: .backwards, range: nil, locale: nil) {
                let typeString = (try? Type(typescript: returnType))?.swiftValue ?? returnType
                str = str.replacingCharacters(in: returnTypeRange, with: typeString)
            }
        }

        return "\(prefix)\(str)"
    }

    public init(typescript: String) throws {
        let regex = "\\(.*\\)"
        guard let range = typescript.range(of: regex,
                                            options: .regularExpression,
                                            range: nil,
                                            locale: nil) else {

            let err = TypeScriptError.invalidFunctionDeclaration
            err.log()
            throw err
        }

        let start = typescript.index(after: range.lowerBound)
        var end: String.Index
        if start == range.upperBound {
            end = start
        } else {
            end = typescript.index(before: range.upperBound)
        }

        let params = String(typescript[start..<end])

        self.functionParams = try params.componentsWithoutPadding(separatedBy: ",")
            .flatMap(PropertyDefinition.init)

        self.typescript = typescript
    }
}

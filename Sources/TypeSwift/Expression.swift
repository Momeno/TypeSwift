//
//  Expression.swift
//  TypeSwift
//
//  Created by Þorvaldur on 18/10/2017.
//

import Foundation

public struct Expression: SwiftStringConvertible, TypeScriptInitializable {
    public let swiftValue: String

    private init(swiftValue: String) {
        self.swiftValue = swiftValue
    }

    public init(typescript: String) throws {
        var str = typescript
        let regexForVariable = "\\$\\{[^\\}]*\\}"

        if let range = str.rangeOfTypeScriptFormatString() {
            let quoteStart: Range<String.Index> = range.lowerBound..<str.index(after: range.lowerBound)
            let quoteEnd: Range<String.Index> = str.index(before: range.upperBound)..<range.upperBound

            str = str.replacingCharacters(in: quoteStart, with: """
            "
            """)
            str = str.replacingCharacters(in: quoteEnd, with: """
            "
            """)

            var stringFormat = String(str[range])


            while let rangeOfVariable = stringFormat.range(of: regexForVariable,
                                                           options: .regularExpression,
                                                           range: nil,
                                                           locale: nil) {

                                                            let varInsertion = String(stringFormat[rangeOfVariable])

                                                            let rangeOfLast = stringFormat.index(before: varInsertion.endIndex)..<varInsertion.endIndex
                                                            let newStr = varInsertion.replacingCharacters(in: rangeOfLast,
                                                                                                          with: ")")
                                                                .replacingOccurrences(of: "${", with: "\\(")

                                                            stringFormat = stringFormat.replacingOccurrences(of: varInsertion,
                                                                                                             with: newStr)
            }

            str = str.replacingCharacters(in: range, with: stringFormat)
        }

        let newRegex = "\\s*new\\s+\\w+\\(.*\\)"
        if let _ = str.range(of: newRegex, options: .regularExpression, range: nil, locale: nil),
            let swapRange = str.range(of: "new") {

            str = str.replacingCharacters(in: swapRange, with: "")
                .trimLeadingWhitespace()
        }

        if str.range(of: regexForVariable,
                     options: .regularExpression,
                     range: nil,
                     locale: nil) != nil {
            try self.init(typescript: str)
        } else {
            self.init(swiftValue: str)
        }
    }
}

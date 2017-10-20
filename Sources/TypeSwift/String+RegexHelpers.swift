//
//  String+RegexHelpers.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 19/10/2017.
//

import Foundation

extension String {
    func rangeOfConstructor() -> Range<String.Index>? {
        let regex = "constructor\\s*\\([^\\)]*\\)\\s*\\{([^\\}]|\\{\\.*\\})*\\}"
        return self.range(of: regex,
                          options: .regularExpression,
                          range: nil,
                          locale: nil)
    }
    
    func extractGenericType() -> (name: String, associates: [String])? {
        let regex = "\\<(.+\\,)*.+\\s*\\>"
        guard let range = self.range(of: regex,
                                     options: .regularExpression,
                                     range: nil,
                                     locale: nil),
            self[range].count > 2 else {
                
                return nil
        }
        
        let innerTypeRange = self.index(after: range.lowerBound)..<self.index(before: range.upperBound)
        
        let trimmed = self.trimLeadingWhitespace()
        
        let name = String(trimmed.prefix(upTo: self.index(of: "<")!))
        let associated = String(self[innerTypeRange]).componentsWithoutPadding(separatedBy: ",")
        
        return (name, associated)
        
    }
    
    func rangeOfImport() -> Range<String.Index>? {
        let regex = "((import\\s+(\\w+|(\\{(\\w|\\n|\\s|\\,)*\\s*\\}))\\s*from\\s+(\\'.*\\'|\\\".*\\\"|`.*`))|import\\s+.*);?"
        
        return self.range(of: regex,
                          options: .regularExpression,
                          range: nil,
                          locale: nil)
    }
    
    func rangeOfTypeScriptFormatString() -> Range<String.Index>? {
        let regex = "(\\`.*\\`)|(\\\".*\\\")|(\\'.*\\')"
        return self.range(of: regex,
                          options: .regularExpression,
                          range: nil,
                          locale: nil)
    }
    
    func rangeOfFunction() -> Range<String.Index>? {
        guard let declarationRange = self.range(of: "((public\\s+|private\\s+|protected\\s+)?(static\\s+)?\\s*)(function\\s)?\\s*\\w*\\(.*\\)(\\s*\\:\\s*\\w+)?",
                                                options: .regularExpression,
                                                range: nil,
                                                locale: nil) else {
            return nil
        }

        let suffix = self.suffix(fromIndex: declarationRange.lowerBound)
        guard let body = suffix.rangeOfBody() else {
            return nil
        }

        let prefix = String(suffix.prefix(upTo: body.upperBound))

        return self.range(of: prefix)
    }
    
    func rangeOfBody() -> Range<String.Index>? {
        var lower: String.Index?
        var upper: String.Index?
        
        var forwardCount = 0
        var matchingCount = 0
        
        for (index, element) in self.enumerated() {
            if element == "{" {
                
                if forwardCount == 0 {
                    lower = self.index(self.startIndex, offsetBy: index)
                }
                
                forwardCount = forwardCount + 1
            } else if element == "}" {
                matchingCount = matchingCount + 1
                if matchingCount == forwardCount && forwardCount > 0 {
                    upper = self.index(self.startIndex, offsetBy: index)
                    break
                }
            }
        }
        guard let low = lower, let up = upper else { return nil }
        return low..<self.index(after:up)
    }
}

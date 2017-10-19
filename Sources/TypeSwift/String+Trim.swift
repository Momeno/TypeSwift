//
//  String+Trim.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 19/10/2017.
//

import Foundation

extension String {
    func trimComments() -> String {
        let commentRegex = "(\\/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+\\/)|(\\/\\/.*)"
        var str = self
        var searchRange = str.startIndex..<str.endIndex
        while let range = str.range(of: commentRegex,
                                    options: .regularExpression,
                                    range: searchRange,
                                    locale: nil) {
                                        let prefix = String(str.prefix(upTo: range.lowerBound))
                                        
                                        // do not remove number notation
                                        if prefix.range(of: "number",
                                                        options: .backwards,
                                                        range: nil,
                                                        locale: nil)?.upperBound != range.lowerBound {
                                            str = str.replacingCharacters(in: range, with: "")
                                                .trimLeadingWhitespace()
                                                .trimTrailingWhitespace()
                                            searchRange = searchRange.lowerBound..<str.endIndex
                                        } else {
                                            searchRange = range.upperBound..<str.endIndex
                                        }
        }
        
        return str
    }
    
    func trimImport() -> String {
        var tmp = self
        while let rangeOfImport = tmp.rangeOfImport() {
            tmp = tmp.replacingCharacters(in: rangeOfImport, with: "")
                .trimLeadingWhitespace()
                .trimTrailingWhitespace()
        }
        return tmp
    }
    
    func suffix(fromInt index: Int) -> String {
        return String(self.suffix(from: self.index(atInt: index)))
    }
    
    func suffix(fromIndex index: Index) -> String {
        return String(self.suffix(from: index))
    }
    
    func trimConstructor() -> String {
        var tmp = self
        while let rangeOfConstructor = tmp.rangeOfConstructor() {
            tmp = tmp.replacingCharacters(in: rangeOfConstructor, with: "")
                .trimTrailingWhitespace()
                .trimLeadingWhitespace()
        }
        return tmp
    }
    
    func trimLeadingCharacters(in set: CharacterSet) -> String {
        guard self.isEmpty == false,
            let scalar = self[startIndex].unicodeScalars.first else { return self }
        
        if set.contains(scalar) {
            return String(self[self.index(after: self.startIndex)..<self.endIndex])
                .trimLeadingCharacters(in: set)
        } else {
            return self
        }
    }
    
    func trimTrailingCharacters(in set: CharacterSet) -> String {
        guard self.isEmpty == false else { return self }
        
        let lastCharIndex = self.index(before: self.endIndex)
        
        guard let scalar = self[lastCharIndex].unicodeScalars.first else { return self }
        
        if set.contains(scalar) {
            return String(self.prefix(self.count-1))
                .trimTrailingCharacters(in: set)
        } else {
            return self
        }
    }
    
    func trimTrailingWhitespace() -> String {
        return self.trimTrailingCharacters(in: .whitespacesAndNewlines)
    }
    
    func trimLeadingWhitespace() -> String {
        return self.trimLeadingCharacters(in: .whitespacesAndNewlines)
    }
}

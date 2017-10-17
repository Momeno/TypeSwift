//
//  String+Help.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum PrefixType {
    case typeAlias

    case model
    case interface

    case module
    case namespace

    case functionDeclaration

    case `import`
}

extension String {
    
    var isTypeScriptFormatString: Bool {
        return self.rangeOfTypeScriptFormatString() == self.startIndex..<self.endIndex
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
        return self.trimTrailingCharacters(in: .whitespaces)
    }
    
    func trimLeadingWhitespace() -> String {
        return self.trimLeadingCharacters(in: .whitespaces)
    }

    func allIndices(of substring: String) -> [String.Index] {
        var searchRange = self.startIndex..<self.endIndex
        var indexes: [String.Index] = []

        while let range = self.range(of: substring,
                                     options: .caseInsensitive,
                                     range: searchRange,
                                     locale: nil) {
            searchRange = range.upperBound..<searchRange.upperBound
            indexes.append(range.lowerBound)
        }
        return indexes
    }
    
    func index(forIndex index: Int, of substring: String) -> String.Index? {
        let indices = allIndices(of: substring)
        guard indices.count > index else { return nil }
        return indices[index]
    }
    
    func getWord(atIndex index: Int, seperation set: CharacterSet) -> String? {
        let components = self.trimLeadingWhitespace()
            .components(separatedBy: set)
        guard index < components.count else { return nil }
        return components[index]
    }
    
    func hasPrefix(_ prefixType: PrefixType) -> Bool {
        switch prefixType {
        case .`import`:
            return importPrefix() != nil
        case .typeAlias:
            return typealiasDeclarationPrefix() != nil
        case .interface:
            return interfaceDeclarationPrefix() != nil
        case .model:
            return modelDeclarationPrefix() != nil
        case .namespace:
            return namespaceDeclarationPrefix() != nil
        case .module:
            return moduleDeclarationPrefix() != nil
        case .functionDeclaration:
            return self.rangeOfFunction()?.lowerBound == self.startIndex
        }
    }

    func rangeOfTypeScriptFormatString() -> Range<String.Index>? {
        let regex = "\\\".*\\\""
        return self.range(of: regex,
                          options: .regularExpression,
                          range: nil,
                          locale: nil)
    }
    
    func rangeOfFunction() -> Range<String.Index>? {
        return self.range(of: "(function\\s)?\\s*\\w*\\(.*\\)\\s*\\:\\s*\\w+",
                          options: .regularExpression,
                          range: nil,
                          locale: nil)
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

    func importPrefix() -> String? {
        guard let word = self.getWord(atIndex: 0, seperation: .whitespaces),
            word == TypeScript.Constants.`import` else {
                return nil
        }
        return word
    }
    
    func modelDeclarationPrefix() -> ModelDeclaration? {
        let working = self.trimLeadingWhitespace()

        var index = working.endIndex
        if working.count >= ModelDeclaration.maxLength {
            index = working.index(working.startIndex, offsetBy: ModelDeclaration.maxLength)
        }

        var str = ""
        for char in String(working[working.startIndex..<index]) {
            str += String(char)
            if let modelDec = ModelDeclaration(rawValue: str) {
                return modelDec
            }
        }
        return nil
    }
    
    func interfaceDeclarationPrefix() -> InterfaceDeclaration? {
        let working = self.trimLeadingWhitespace()
        guard let index = working.index(of: " ") else {
            return nil
        }

        let start = working.startIndex
        var end = index
        if working.hasPrefix(TypeScript.Constants.export) {
            let newWorking = String(working.suffix(from: index))
                .trimLeadingWhitespace()
            
            guard let secondEndIndex = newWorking.index(of: " ") else {
                return nil
            }
            
            let nextWord = String(newWorking[newWorking.startIndex..<secondEndIndex])
            guard let nextWordStart = working.range(of: nextWord)?.lowerBound else {
                return nil
            }
            
            let nextSpace = working.index(nextWordStart, offsetBy: nextWord.count)
            
            end = nextSpace
        }

        return InterfaceDeclaration(rawValue: String(working[start..<end]))
    }

    func typealiasDeclarationPrefix() -> String? {
        guard let word = self.getWord(atIndex: 0, seperation: .whitespaces),
            word == TypeScript.Constants.type else {
                return nil
        }
        return word
    }

    func moduleDeclarationPrefix() -> String? {
        guard let word = self.getWord(atIndex: 0, seperation: .whitespaces),
            word == TypeScript.Constants.module else {
            return nil
        }
        return word
    }

    func namespaceDeclarationPrefix() -> String? {
        guard let word = self.getWord(atIndex: 0, seperation: .whitespaces),
            word == TypeScript.Constants.namespace else {
                return nil
        }
        return word
    }
}

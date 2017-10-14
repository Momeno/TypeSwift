//
//  String+Help.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum PrefixType {
    case modelDeclaration
    case interfaceDeclaration
}

extension String {
    func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
    
    func trimLeadingWhitespace() -> String {
        guard self.isEmpty == false,
            let scalar = self[startIndex].unicodeScalars.first else { return self }
        
        if CharacterSet.whitespaces.contains(scalar) {
            return String(self[self.index(after: self.startIndex)..<self.endIndex])
                .trimLeadingWhitespace()
        } else {
            return self
        }
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
        case .interfaceDeclaration:
            return interfaceDeclarationPrefix() != nil
        case .modelDeclaration:
            return modelDeclarationPrefix() != nil
        }
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
                }
            }
        }
        guard let low = lower, let up = upper else { return nil }
        return low..<self.index(after:up)
    }
    
    func modelDeclarationPrefix() -> ModelDeclaration? {
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
        
        return ModelDeclaration(rawValue: String(working[start..<end]))
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
}

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
}

extension String {
    
    var endOfExpressionIndex: String.Index {
        let indexOfNewLine = self.index(of: "\n")
        let indexOfSemiComma = self.index(of: ";")
        
        switch (indexOfNewLine, indexOfSemiComma) {
        case (.some, .some):
            return indexOfNewLine! > indexOfSemiComma! ? indexOfSemiComma! : indexOfNewLine!
        case (.some, .none):
            return indexOfNewLine!
        case (.none, .some):
            return indexOfSemiComma!
        case (.none, .none):
            return self.endIndex
        }
    }
    
    var isTypeScriptFormatString: Bool {
        return self.rangeOfTypeScriptFormatString() == self.startIndex..<self.endIndex
    }
    
    func componentsWithoutPadding(separatedBy string: String) -> [String] {
        return self.components(separatedBy: string)
            .map {
                return $0.trimLeadingWhitespace()
                    .trimTrailingWhitespace()
            }
            .filter { $0.isEmpty == false }
    }
    
    func componentsWithoutPadding(separatedBy characterSet: CharacterSet) -> [String] {
        return self.components(separatedBy: characterSet)
            .map {
                return $0.trimLeadingWhitespace()
                    .trimTrailingWhitespace()
            }
            .filter { $0.isEmpty == false }
    }
    
    func index(atInt index: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: index)
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

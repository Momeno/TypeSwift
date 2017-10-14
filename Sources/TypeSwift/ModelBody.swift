//
//  ModelBody.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct ModelBody: RawRepresentable, SwiftStringConvertible {
    
    let rawValue: String
    let properties: [(access: PropertyAccessLevel, perm: Permission, def: PropertyDefinition)]
    
    var swiftValue: String {
        let joined = properties.map { access, perm, def in
            "\t\(access.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
            }
            .joined(separator: "\n")
        return "{\n\(joined)\n}"
    }
    
    init?(rawValue: String) {
        guard let index = rawValue.index(of: "{") else { return nil }
        let start = rawValue.index(after: index)
        
        guard let end = rawValue.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            return nil
        }
        
        let workingString = rawValue[start..<end]
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))

        var arr: [(PropertyAccessLevel, Permission, PropertyDefinition)] = []

        for element in components {
            if element.isEmpty { continue }
            
            var element = element
            element = element.trimLeadingWhitespace()
                .trimTrailingWhitespace()
            
            var access = PropertyAccessLevel.`public`
            
            guard let firstWord = element.getWord(atIndex: 0, seperation: .whitespaces) else {
                return nil
            }
            
            guard let secondWord = element.getWord(atIndex: 1, seperation: .whitespaces) else {
                return nil
            }
            
            var permission: Permission = .readAndWrite
            if secondWord.hasPrefix(":") || firstWord.hasSuffix(":") {
                guard let definition = PropertyDefinition(rawValue: element) else {
                    return nil
                }
                arr.append((access, permission, definition))
                continue
            } else if let acc = PropertyAccessLevel(rawValue: firstWord) {
                access = acc
                element = String(element.suffix(from: element.range(of: firstWord)!.upperBound))
                    .trimLeadingWhitespace()
            }
            
            guard let word = element.getWord(atIndex: 0, seperation: .whitespaces) else {
                return nil
            }

            let wordAfter = element.getWord(atIndex: 1, seperation: .whitespaces)
            
            let readonly = TypeScript.Constants.readonly
            if word == readonly
                && word.hasSuffix(":") == false
                && wordAfter?.hasPrefix(":") == false {

                permission = .readonly
                element = String(element.suffix(from: element.index(element.startIndex,
                                                             offsetBy: readonly.count)))
                    .trimLeadingWhitespace()
            }
            
            guard let definition = PropertyDefinition(rawValue: element) else {
                return nil
            }
            
            arr.append((access, permission, definition))
        }
        self.properties = arr
        self.rawValue = rawValue
    }
}

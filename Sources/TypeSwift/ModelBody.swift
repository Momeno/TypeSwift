//
//  ModelBody.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct ModelBody: TypeScriptInitializable, SwiftStringConvertible {
    
    let properties: [(access: PropertyAccessLevel, perm: Permission, def: PropertyDefinition)]
    
    var swiftValue: String {
        let joined = properties.map { access, perm, def in
            "\t\(access.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
            }
            .joined(separator: "\n")
        return "{\n\(joined)\n}"
    }
    
    init(typescript: String) throws {
        guard let index = typescript.index(of: "{") else {
            throw TypeScriptError.cannotDeclareModelWithoutBody
        }

        let start = typescript.index(after: index)
        
        guard let end = typescript.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            throw TypeScriptError.cannotDeclareModelWithoutBody
        }
        
        let workingString = typescript[start..<end]
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))

        var arr: [(PropertyAccessLevel, Permission, PropertyDefinition)] = []

        for element in components {
            if element.isEmpty { continue }
            
            var element = element
            element = element.trimLeadingWhitespace()
                .trimTrailingWhitespace()
            
            var access = PropertyAccessLevel.`public`
            
            guard let firstWord = element.getWord(atIndex: 0, seperation: .whitespaces),
                let secondWord = element.getWord(atIndex: 1, seperation: .whitespaces) else {
                throw TypeScriptError.invalidDeclaration(element)
            }

            var permission: Permission = .readAndWrite
            if secondWord.hasPrefix(":") || firstWord.hasSuffix(":") {
                let definition = try PropertyDefinition(typescript: element)

                arr.append((access, permission, definition))
                continue
            } else if let acc = PropertyAccessLevel(rawValue: firstWord) {
                access = acc
                element = String(element.suffix(from: element.range(of: firstWord)!.upperBound))
                    .trimLeadingWhitespace()
            }
            
            guard let word = element.getWord(atIndex: 0, seperation: .whitespaces) else {
                throw TypeScriptError.invalidDeclaration(element)
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
            
            let definition = try PropertyDefinition(typescript: element)
            
            arr.append((access, permission, definition))
        }
        self.properties = arr
    }
}

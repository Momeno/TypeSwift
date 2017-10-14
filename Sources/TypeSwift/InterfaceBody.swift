//
//  InterfaceBody.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

struct InterfaceBody: RawRepresentable, SwiftStringConvertible {

    let rawValue: String
    let properties: [(perm: Permission, def: PropertyDefinition)]

    var swiftValue: String {
        return "{\n" + self.properties.map { perm, def in
            return "\tvar \(def.swiftValue) { \(perm.swiftValue) }"
        }
        .joined(separator: "\n") + "\n}"
    }

    init?(rawValue: String) {
        guard let index = rawValue.index(of: "{") else { return nil }
        let start = rawValue.index(after: index)
        
        guard let end = rawValue.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            return nil
        }

        let workingString = rawValue[start..<end]
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))
        var arr: [(Permission, PropertyDefinition)] = []
        for element in components {
            if element.isEmpty { continue }
            
            var element = element
            element = element.trimLeadingWhitespace()
                .trimTrailingWhitespace()

            var permission = Permission.readAndWrite

            let readonly = TypeScript.Constants.readonly

            if element.hasPrefix(readonly) {
                permission = .readonly
                element = String(element.suffix(from: element.index(element.startIndex,
                                                                    offsetBy: readonly.count)))
                    .trimLeadingWhitespace()
            }

            guard let definition = PropertyDefinition(rawValue: element) else {
                return nil
            }

            arr.append((permission, definition))
        }
        self.properties = arr
        self.rawValue = rawValue
    }
}

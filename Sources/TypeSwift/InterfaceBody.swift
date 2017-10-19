//
//  InterfaceBody.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

public struct InterfaceBody: TypeScriptInitializable, SwiftStringConvertible {

    let properties: [(perm: Permission, def: PropertyDefinition)]

    public var swiftValue: String {
        return "{\n" + self.properties.map { perm, def in
            return "var \(def.swiftValue) { \(perm.swiftValue) }"
        }
        .joined(separator: "\n") + "\n}"
    }

    public init(typescript: String) throws {
        guard let index = typescript.index(of: "{") else {
            throw TypeScriptError.cannotDeclareInterfaceWithoutBody
        }

        let start = typescript.index(after: index)

        guard let end = typescript.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            throw TypeScriptError.cannotDeclareInterfaceWithoutBody
        }

        let workingString = typescript[start..<end]
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))
            .map {
                $0.trimLeadingWhitespace().trimTrailingWhitespace()
            }
            .filter { $0.isEmpty == false }
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

            let definition = try PropertyDefinition(typescript: element)

            arr.append((permission, definition))
        }
        self.properties = arr
    }
}

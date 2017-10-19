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
        guard let body = typescript.rangeOfBody() else {
            throw TypeScriptError.cannotDeclareInterfaceWithoutBody
        }

        let start = typescript.index(after: body.lowerBound)
        let end = typescript.index(before: body.upperBound)

        let workingString = String(typescript[start..<end])
        let components = workingString.componentsWithoutPadding(separatedBy: CharacterSet(charactersIn: "\n;"))
        
        self.properties = try components
            .map {
                var element = $0
                var permission = Permission.readAndWrite
                let readonly = TypeScript.Constants.readonly

                if element.hasPrefix(readonly) {
                    permission = .readonly
                    element = element.suffix(fromInt: readonly.count)
                        .trimLeadingWhitespace()
                }
                
                let definition = try PropertyDefinition(typescript: element)
                return (permission, definition)
            }
    }
}

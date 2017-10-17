//
//  ModelBody.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

public struct ModelBody: TypeScriptInitializable, SwiftStringConvertible {
    
    let properties: [(access: PropertyAccessLevel, scope: PropertyScope, perm: Permission, def: PropertyDefinition)]
    
    public var swiftValue: String {
        let joined = properties.map {
                let access = $0.0
                let scope = $0.1
                let perm = $0.2
                let def = $0.3

                switch scope {
                case .none:
                    return "\(access.swiftValue)\(scope.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
                case .`static`:
                    return "\(access.swiftValue) \(scope.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
                }
            }
            .joined(separator: "\n")
        return "{\n\(joined)\n}"
    }
    
    public init(typescript: String) throws {
        guard let index = typescript.index(of: "{") else {
            throw TypeScriptError.cannotDeclareModelWithoutBody
        }

        let start = typescript.index(after: index)
        
        guard let end = typescript.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            throw TypeScriptError.cannotDeclareModelWithoutBody
        }
        
        var workingString = String(typescript[start..<end])

        var functions: [Function] = []
        while let functionRange = workingString.rangeOfFunction() {
            let start = functionRange.lowerBound
            let suffix = String(workingString.suffix(from: start))
            
            guard let rangeOfBody = suffix.rangeOfBody() else {
                throw TypeScriptError.invalidFunctionDeclaration
            }
            let totalFunctionRange = start...rangeOfBody.upperBound
            functions.append(try Function(typescript: String(workingString[totalFunctionRange])))
            workingString = workingString.replacingCharacters(in: totalFunctionRange, with: "")
        }
        
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))

        var arr: [(PropertyAccessLevel, PropertyScope, Permission, PropertyDefinition)] = []

        for element in components {
            if element.isEmpty { continue }
            
            var element = element
            element = element.trimLeadingWhitespace()
                .trimTrailingWhitespace()
            
            var access = PropertyAccessLevel.`public`
            var scope: PropertyScope = .none
            var permission: Permission = .readAndWrite

            let properties = element.components(separatedBy: ":")
                .map {
                    $0.trimLeadingWhitespace()
                        .trimTrailingWhitespace()
                }
                .filter {
                    $0.isEmpty == false
                }

            guard properties.count == 2 else {
                throw TypeScriptError.invalidDeclaration(element)
            }

            let nameDeclarationObjects = properties.first?
                .components(separatedBy: " ")
                .map { str in
                    str.trimTrailingWhitespace()
                        .trimLeadingWhitespace()
                }
                .filter {
                    return $0.isEmpty == false
                }

            guard let nameDeclaration = nameDeclarationObjects else {
                throw TypeScriptError.invalidDeclaration(element)
            }

            guard let name = nameDeclaration.last else {
                throw TypeScriptError.invalidDeclaration(element)
            }

            for element in nameDeclaration {
                if let scp = PropertyScope(rawValue: element) {
                    scope = scp
                } else if let acc = PropertyAccessLevel(rawValue: element) {
                    access = acc
                } else if let perm = Permission(rawValue: element) {
                    permission = perm
                }
            }

            let definitionRaw = "\(name): \(properties[1])"
            let definition = try PropertyDefinition(typescript: definitionRaw)
            
            arr.append((access, scope, permission, definition))
        }
        self.properties = arr
    }
}

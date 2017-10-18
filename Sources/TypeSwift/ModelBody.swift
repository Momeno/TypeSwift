//
//  ModelBody.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

public struct ModelBody: TypeScriptInitializable, SwiftStringConvertible {
    
    let properties: [(access: PropertyAccessLevel, scope: PropertyScope, perm: Permission, def: PropertyDefinition)]
    let functions: [Function]

    public var swiftValue: String {
        let joined = properties.map {
                let access = $0.0; let scope = $0.1; let perm = $0.2; let def = $0.3

                switch scope {
                case .none:
                    return "\(access.swiftValue)\(scope.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
                case .`static`:
                    return "\(access.swiftValue) \(scope.swiftValue) \(perm.letOrVar) \(def.swiftValue)"
                }
            }
            .joined(separator: "\n")
        let functionsString = self.functions.map {
            $0.swiftValue
        }
        .joined(separator: "\n")
        return "{\n\(joined)\n\(self.getSwiftInitMethods())\n\(functionsString.isEmpty == false ? functionsString + "\n" : "")}"
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

            let suffix = String(workingString.suffix(from: functionRange.lowerBound))
            guard let rangeOfBody = suffix.rangeOfBody() else {
                throw TypeScriptError.invalidFunctionDeclaration
            }
            let totalFunctionRange = suffix.startIndex...rangeOfBody.upperBound
            functions.append(try Function(typescript: String(suffix[totalFunctionRange])))
            workingString = workingString.replacingCharacters(in: totalFunctionRange, with: "")
        }
        
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))
            .map { $0.trimTrailingWhitespace().trimLeadingWhitespace() }
            .filter { $0.isEmpty == false }

        var arr: [(PropertyAccessLevel, PropertyScope, Permission, PropertyDefinition)] = []

        for element in components {
            if element.isEmpty { continue }
            
            var element = element
            element = element.trimLeadingWhitespace()
                .trimTrailingWhitespace()
            
            var access = PropertyAccessLevel.`public`
            var scope: PropertyScope = .none
            var permission: Permission = .readAndWrite

            let nameDeclarationEnd = element.index(of: ":") ?? (element.index(of: "=") ?? element.endIndex)
            let afterColon = String(element.suffix(from: nameDeclarationEnd))
                .trimTrailingWhitespace()
                .trimLeadingWhitespace()

            let nameDeclaration = String(element.prefix(upTo: nameDeclarationEnd))
                .components(separatedBy: " ")
                .filter { $0.isEmpty == false }

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

            let definitionRaw = "\(name)\(afterColon)"
            let definition = try PropertyDefinition(typescript: definitionRaw)
            
            arr.append((access, scope, permission, definition))
        }
        self.properties = arr
        self.functions = functions
    }

    func getSwiftInitMethods() -> String {
        let constructParams: (Bool) -> String = { hasLabels in

            return self.properties.map { tuple in
                let def = tuple.3
                var variableName: String
                var swiftType: String
                switch def {
                case .definite(let name, let type, _),
                     .optional(let name, let type):
                    variableName = name
                    swiftType = type?.swiftValue ?? "Any"
                }
                if tuple.scope.isStatic == false {
                    if hasLabels {
                        return "\(variableName): \(swiftType)"
                    } else {
                        return "_ \(variableName): \(swiftType)"
                    }
                } else {
                    return ""
                }
            }
            .filter { $0.isEmpty == false }
            .joined(separator: ", ")
        }

        let bodyParams = self.properties.map {
            var variableName: String
            switch $0.def {
            case .definite(let name, _, _),
                 .optional(let name, _):
                variableName = name
            }
            if $0.scope.isStatic == false {
                return "self.\(variableName) = \(variableName)"
            } else {
                return ""
            }
        }
        .filter { $0.isEmpty == false}
        .joined(separator: "\n")

        let cStyleParams = constructParams(false)
        let cStyleInit = "init(\(cStyleParams)) {\n\(bodyParams)\n}"
        let regularInit = "public init(\(constructParams(true))) {\n\(bodyParams)\n}"
        let initString = "\(cStyleInit)\n\(regularInit)"

        return bodyParams.isEmpty ? "" : initString
    }
}

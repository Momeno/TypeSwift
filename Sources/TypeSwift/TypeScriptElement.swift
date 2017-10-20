//
//  TypeScriptElement.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 19/10/2017.
//

import Foundation

public enum TypeScriptElement: TypeScriptInitializable, SwiftStringConvertible {
    case `typealias`(String, Type)
    case function(Function)
    case model(Model)
    case interface(Interface)
    
    public var swiftValue: String {
        switch self {
        case .`typealias`(let name, let type):
            return "typealias \(name) = \(type.swiftValue)"
        case .function(let function):
            return function.swiftValue
        case .interface(let interface):
            return interface.swiftValue
        case .model(let model):
            return model.swiftValue
        }
    }
    
    public init(typescript: String) throws {
        let working = typescript
            .trimLeadingWhitespace()
            .trimTrailingWhitespace()
            .trimComments()
            .trimImport()
            .trimConstructor()

        if working.hasPrefix(.functionDeclaration) {
            guard let functionRange = working.rangeOfFunction() else {
                let err = TypeScriptError.invalidFunctionDeclaration
                err.log()
                throw err
            }
            self = .function(try Function(typescript: String(working[functionRange])))
        } else if working.hasPrefix(.typeAlias) {
            
            let typealiasKeyword = working.typealiasDeclarationPrefix()!
            
            let suffix = working.suffix(fromInt: typealiasKeyword.count)
            
            let components = suffix.componentsWithoutPadding(separatedBy: "=")
            
            let nameRaw = components[0]
            guard let typeRaw = components[1].trimLeadingWhitespace()
                .getWord(atIndex: 0, seperation: CharacterSet(charactersIn: "\n;")) else {
                    let err = TypeScriptError.invalidTypealias
                    err.log()
                    throw err
            }
            self = .`typealias`(nameRaw, try Type(typescript: typeRaw))
            
        } else if let bodyRange = working.rangeOfBody() {
            let raw = String(working[working.startIndex..<bodyRange.upperBound])
            
            if working.hasPrefix(.interface) {
            
                let interface = try Interface(typescript: raw)
                
                self = .interface(interface)
                
            } else if working.hasPrefix(.model) {
                let model = try Model(typescript: raw)
                self = .model(model)
            } else {
                let err = TypeScriptError.unsupportedTypeScript(typescript)
                err.log()
                throw err
            }
        } else {
            let err = TypeScriptError.unsupportedTypeScript(typescript)
            err.log()
            throw err
        }
    }
}

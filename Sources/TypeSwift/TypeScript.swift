//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum TypeScript: TypeScriptInitializable, SwiftStringConvertible {

    //case conformingModel(AccessLevel?, ModelDeclaration, String, String/*protocol conformation*/, ModelBody)
    case model(Model)
    case interface(Interface)
    indirect case composed(TypeScript?, TypeScript?)
    
    var swiftValue: String {
        switch self {
        case .interface(let interface):
            return interface.swiftValue
        case .model(let model):
            return model.swiftValue
        case .composed(let type1, let type2):
            var composed = ""
            if let ts1 = type1?.swiftValue {
                composed += ts1 + "\n\n"
            }
            if let ts2 = type2?.swiftValue {
                composed += ts2 + "\n\n"
            }
            return composed.trimTrailingCharacters(in: .newlines)
                .trimLeadingCharacters(in: .newlines)
        }
    }
    
    init(typescript: String) throws {
        let working = typescript
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)
        
        guard let bodyRange = working.rangeOfBody() else {
            throw TypeScriptError.typeScriptEmpty
        }

        let raw = String(working[working.startIndex..<bodyRange.upperBound])
        
        if working.hasPrefix(.interfaceDeclaration) {
            
            let interface = try Interface(typescript: raw)
            
            let typescript1: TypeScript = .interface(interface)
            
            var nextTypeScript = ""
            if working.endIndex > bodyRange.upperBound {
                let nextTypeScriptStart = working.index(after: bodyRange.upperBound)
                nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                    .trimLeadingCharacters(in: .whitespacesAndNewlines)
            }

            
            if (nextTypeScript.hasPrefix(.interfaceDeclaration) ||
                nextTypeScript.hasPrefix(.modelDeclaration)) {
                
                let typescript2 = try TypeScript(typescript: nextTypeScript)
                self = .composed(typescript1, typescript2)
            } else {
                self = typescript1
            }
            
        } else if working.hasPrefix(.modelDeclaration) {
            
            let model = try Model(typescript: raw)
            
            var nextTypeScript = ""
            
            if working.endIndex > bodyRange.upperBound {
                let nextTypeScriptStart = working.index(after: bodyRange.upperBound)
                nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                    .trimLeadingCharacters(in: .whitespacesAndNewlines)
            }
            
            let typescript1: TypeScript = .model(model)
            if (nextTypeScript.hasPrefix(.interfaceDeclaration) ||
                nextTypeScript.hasPrefix(.modelDeclaration)) {
                
                let typescript2 = try TypeScript(typescript: nextTypeScript)
                self = .composed(typescript1, typescript2)
            } else {
                self = typescript1
            }
        } else {
            throw TypeScriptError.unsupportedTypeScript(typescript)
        }
    }
}

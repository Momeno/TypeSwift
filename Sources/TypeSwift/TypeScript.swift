//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum TypeScript: RawRepresentable, SwiftStringConvertible {

    //case conformingModel(AccessLevel?, ModelDeclaration, String, String/*protocol conformation*/, ModelBody)
    case model(ModelDeclaration, String, ModelBody)
    case interface(InterfaceDeclaration, String, InterfaceBody)
    indirect case composed(TypeScript?, TypeScript?)

    var rawValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        case .model(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        case .composed(let typescript1, let typescript2):
            var composed = ""
            if let ts1 = typescript1?.rawValue {
                composed += ts1 + "\n\n"
            }
            if let ts2 = typescript2?.rawValue {
                composed += ts2 + "\n\n"
            }
            return composed
        }
    }
    
    var swiftValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.swiftValue) \(name) \(body.swiftValue)"
                .trimTrailingCharacters(in: .newlines)
                .trimLeadingCharacters(in: .newlines)
        case .model(let decl, let name, let body):
            return "\(decl.swiftValue) \(name) \(body.swiftValue)"
                .trimTrailingCharacters(in: .newlines)
                .trimLeadingCharacters(in: .newlines)
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
    
    init?(rawValue: String) {
        let working = rawValue
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)
        
        if working.hasPrefix(.interfaceDeclaration) {
            guard let bodyRange = working.rangeOfBody() else {
                return nil
            }
            guard let body = InterfaceBody(rawValue: String(working[bodyRange])) else {
                return nil
            }
            guard let interface = working.interfaceDeclarationPrefix() else {
                return nil
            }
            
            if bodyRange.upperBound >= working.endIndex {
                
                let offsetedIndex = working.index(working.startIndex, offsetBy: interface.rawValue.count)
                let suffix = String(working.suffix(from: offsetedIndex))
                guard let indexOfSpace = suffix.index(of: " ") else {
                    return nil
                }
                
                guard let name = String(suffix.suffix(from: indexOfSpace))
                    .getWord(atIndex: 0, seperation: .whitespaces) else {
                       
                    return nil
                }
                
                self = .interface(interface, name, body)
                return
            } else {
                let nextTypeScriptStart = working.index(after: bodyRange.upperBound)
                
                let nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                    .trimLeadingCharacters(in: .whitespacesAndNewlines)
                let typescript1 = TypeScript(rawValue: String(working.prefix(upTo: nextTypeScriptStart)))
                if (nextTypeScript.hasPrefix(.interfaceDeclaration) ||
                    nextTypeScript.hasPrefix(.modelDeclaration)) {
                    
                    let typescript2 = TypeScript(rawValue: String(working.suffix(from: nextTypeScriptStart)))
                    self = .composed(typescript1, typescript2)
                    return
                } else {
                    guard typescript1 != nil else {
                        return nil
                    }
                    self = typescript1!
                    return
                }
            }
        } else if working.hasPrefix(.modelDeclaration) {
            guard let bodyRange = working.rangeOfBody() else {
                return nil
            }
            guard let body = ModelBody(rawValue: String(working[bodyRange])) else {
                return nil
            }
            guard let modelDec = working.modelDeclarationPrefix() else {
                return nil
            }
            
            if bodyRange.upperBound >= working.endIndex {
                let offsetedIndex = working.index(working.startIndex, offsetBy: modelDec.rawValue.count)
                let suffix = String(working.suffix(from: offsetedIndex))
                guard let indexOfSpace = suffix.index(of: " ") else {
                    return nil
                }
                
                guard let name = String(suffix.suffix(from: indexOfSpace))
                    .getWord(atIndex: 0, seperation: .whitespaces) else {
                        return nil
                }
                
                self = .model(modelDec, name, body)
                return
            } else {
                let nextTypeScriptStart = working.index(after: bodyRange.upperBound)
                let nextTypeScript = String(working.suffix(from: nextTypeScriptStart))
                    .trimLeadingCharacters(in: .whitespacesAndNewlines)
                let typescript1 = TypeScript(rawValue: String(working.prefix(upTo: nextTypeScriptStart)))
                if nextTypeScript.hasPrefix(.interfaceDeclaration) ||
                    nextTypeScript.hasPrefix(.modelDeclaration) {
                    
                    let typescript2 = TypeScript(rawValue: String(working.suffix(from: nextTypeScriptStart)))
                    self = .composed(typescript1, typescript2)
                    return
                } else {
                    guard typescript1 != nil else {
                        return nil
                    }
                    self = typescript1!
                    return
                }
            }
            
        }

        return nil
    }
}

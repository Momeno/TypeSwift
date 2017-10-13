//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum NewLine: String {
    case newLine = "\n"
}

enum TypeScript: RawRepresentable, SwiftStringConvertible {

    //case model(AccessLevel?, ModelDeclaration, String, ModelBody)
    //case conformingModel(AccessLevel?, ModelDeclaration, String, String/*protocol conformation*/, ModelBody)
    case interface(InterfaceDeclaration, String, InterfaceBody)
    case newLine(NewLine)
    indirect case composed(TypeScript, NewLine, TypeScript)

    var rawValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        case .newLine(let newLineSring):
            return newLineSring.rawValue
        case .composed(let typescript1, let newLine, let typescript2):
            return "\(typescript1.rawValue)\(newLine.rawValue)\(typescript2.rawValue)"
        }
    }
    
    var swiftValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.swiftValue) \(name) \(body.swiftValue)"
        case .newLine(let new):
            return new.rawValue
        case .composed(let type1, let new, let type2):
            return "\(type1.swiftValue)\(new.rawValue)\(type2.swiftValue)"
        }
    }
    
    init?(rawValue: String) {
        return nil
    }
}

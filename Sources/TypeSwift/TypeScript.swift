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
    indirect case composed(TypeScript, TypeScript)

    var rawValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        case .model(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        case .composed(let typescript1, let typescript2):
            return "\(typescript1.rawValue)\n\n\(typescript2.rawValue)"
        }
    }
    
    var swiftValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.swiftValue) \(name) \(body.swiftValue)"
        case .model(let decl, let name, let body):
            return "\(decl.swiftValue) \(name) \(body.swiftValue)"
        case .composed(let type1, let type2):
            return "\(type1.swiftValue)\n\n\(type2.swiftValue)"
        }
    }
    
    init?(rawValue: String) {
        if rawValue.hasPrefix(.interfaceDeclaration) {
            
        } else if rawValue.hasPrefix(.modelDeclaration) {
            
        }
        return nil
    }
}

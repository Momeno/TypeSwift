//
//  TypeScript.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum TypeScript: RawRepresentable, SwiftStringConvertible {
    //case model(ModelDeclaration, String, ModelBody)
    //case conformingModel(ModelDeclaration, String, String, ModelBody)
    case interface(InterfaceDeclaration, String, InterfaceBody)
    
    var rawValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.rawValue) \(name) \(body.rawValue)"
        }
    }
    
    var swiftValue: String {
        switch self {
        case .interface(let dec, let name, let body):
            return "\(dec.swiftValue) \(name) \(body.swiftValue)"
        }
    }
    
    init?(rawValue: String) {
        return nil
    }
}

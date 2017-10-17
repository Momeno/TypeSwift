//
//  ModelDeclaration.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum ModelDeclaration: String, SwiftStringConvertible {
    case `class`
    case publicClass = "export class"
    case defaultExportClass = "default export class"
    
    var swiftValue: String {
        switch self {
        case .`class`:
            return "struct"
        case .publicClass:
            return "public struct"
        case .defaultExportClass:
            return "public struct"
        }
    }

    static var allCases: [ModelDeclaration] {
        return [ .`class`, .publicClass, .defaultExportClass ]
    }

    static var maxLength: Int {
        return allCases.reduce(0, { (result, dec) -> Int in
            return dec.rawValue.count > result ? dec.rawValue.count : result
        })
    }
}

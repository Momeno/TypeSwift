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
    
    var swiftValue: String {
        switch self {
        case .`class`:
            return "struct"
        case .publicClass:
            return "public struct"
        }
    }
}

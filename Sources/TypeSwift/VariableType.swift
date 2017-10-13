//
//  VariableType.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 12/10/2017.
//

import Foundation

enum VariableType: String, SwiftStringConvertible {
    case `let`
    case const
    
    var swiftValue: String {
        switch self {
        case .let:
            return "var"
        case .const:
            return "let"
        }
    }
}

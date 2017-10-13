//
//  InterfaceDeclaration.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum InterfaceDeclaration: String, SwiftStringConvertible {
    case publicInterface = "export interface"
    case interface = "interface"
    
    var swiftValue: String {
        switch self {
        case .interface:
            return "protocol"
        case .publicInterface:
            return "public protocol"
        }
    }
}

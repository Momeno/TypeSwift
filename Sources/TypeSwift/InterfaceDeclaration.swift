//
//  InterfaceDeclaration.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

public enum InterfaceDeclaration: String, SwiftStringConvertible {
    case publicInterface = "export interface"
    case interface = "interface"
    
    public var swiftValue: String {
        switch self {
        case .interface:
            return "protocol"
        case .publicInterface:
            return "public protocol"
        }
    }
}

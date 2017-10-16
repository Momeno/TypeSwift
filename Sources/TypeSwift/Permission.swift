//
//  Permission.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur on 16/10/2017.
//

import Foundation

enum Permission: SwiftStringConvertible {
    case readonly
    case readAndWrite

    var swiftValue: String {
        switch self {
        case .readAndWrite:
            return "get set"
        case .readonly:
            return "get"
        }
    }

    var letOrVar: String {
        switch self {
        case .readAndWrite:
            return "var"
        case .readonly:
            return "let"
        }
    }

    init?(rawValue: String) {
        if rawValue.isEmpty {
            self = .readAndWrite
        } else if rawValue == "readonly" {
            self = .readonly
        } else {
            return nil
        }
    }
}

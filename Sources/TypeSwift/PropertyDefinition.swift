//
//  PropertyDefinition.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

enum Permission: RawRepresentable, SwiftStringConvertible {
    case readonly
    case readAndWrite
    
    var rawValue: String {
        switch self {
        case .readonly:
            return "readonly"
        case .readAndWrite:
            return ""
        }
    }

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

enum PropertyDefinition: TypeScriptInitializable, SwiftStringConvertible {
    case optional(String, Type)
    case definite(String, Type)
    case indexSignature(String, Type, Type)
    
    var swiftValue: String {
        switch self {
        case .definite(let name, let type):
            return "\(name): \(type.swiftValue)"
        case .optional(let name, let type):
            return "\(name): \(type.swiftValue)?"
        case .indexSignature(_, _, _):
            fatalError("Index Signatures are not supported")
        }
    }

    init(typescript: String) throws {
        guard let first = typescript.first else {
            throw TypeScriptError.invalidDeclaration(typescript)
        }

        if first == "[" {
            // index signature
            let msg = "[ at the start of a property declaration is a sign of an Index Signature, which is not supported"
            fatalError(msg)
        } else {
            let components = typescript.components(separatedBy: ":")

            guard components.count == 2 else {
                throw TypeScriptError.invalidDeclaration(typescript)
            }

            var isOptional = false

            var name = components[0].trimmingCharacters(in: .whitespaces)
            let typeRaw = components[1].trimmingCharacters(in: .whitespaces)

            let type = try Type(typescript: typeRaw)

            if name.hasSuffix("?") {
                isOptional = true
                name = String(name[name.startIndex..<name.index(before: name.endIndex)])
            }

            if isOptional {
                self = .optional(name, type)
            } else {
                self = .definite(name, type)
            }
        }
    }
}

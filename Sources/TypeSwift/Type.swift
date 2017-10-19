//
//  Type.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 12/10/2017.
//

import Foundation

public indirect enum Type: TypeScriptInitializable, SwiftStringConvertible {
    case any
    case string
    case boolean
    case number
    case void
    case swiftNumber(SwiftNumber)
    case array(Type)
    case tuple(Type, Type)
    case generic(String, [Type])
    case custom(String)

    public init(typescript: String) throws {
        if typescript == TypeScript.Constants.string {
            self = .string
        } else if typescript == TypeScript.Constants.boolean {
            self = .boolean
        } else if typescript == TypeScript.Constants.void {
            self = .void
        } else if typescript == TypeScript.Constants.number {
            self = .number
        } else if typescript == TypeScript.Constants.any {
            self = .any
        } else if typescript.hasPrefix(TypeScript.Constants.number) {
            guard typescript.count > 8 else {
                throw TypeScriptError.invalidDeclaration(typescript)
            }

            let index = typescript.index(typescript.startIndex, offsetBy: 8)
            let suffix = String(typescript.suffix(from: index))
            let swiftNumRaw = String(suffix.prefix(suffix.count - 2))
            guard let swiftNum = SwiftNumber(rawValue: swiftNumRaw) else {
                throw TypeScriptError.invalidDeclaration(swiftNumRaw)
            }
            self = .swiftNumber(swiftNum)
        } else if typescript.hasPrefix("Array<") && typescript.hasSuffix(">") {
            let idx = typescript.index(of: "<")!
            let start = typescript.index(after: idx)
            let end = typescript.index(typescript.startIndex, offsetBy: typescript.count - 1)

            let rawType = String(typescript[start..<end])
            let type = try Type(typescript: rawType)

            self = .array(type)
        } else if typescript.hasPrefix("[") && typescript.hasSuffix("]") {

            var bracketsStartCount = 0
            var bracketsEndCount = 0

            var index: String.Index?

            for (idx, char) in typescript.enumerated() {
                if char == "[" {
                    bracketsStartCount += 1
                } else if char == "]" {
                    bracketsEndCount += 1
                }

                if ((bracketsStartCount - bracketsEndCount) == 1) && char == "," {
                    index = typescript.index(typescript.startIndex, offsetBy: idx)
                    break
                }
            }

            guard let indexOfComma = index else {
                throw TypeScriptError.invalidDeclaration(typescript)
            }

            let spaceIndex = typescript.index(after: indexOfComma)
            let secondIndex = typescript.index(after: spaceIndex)

            let substring1 = String(typescript[typescript.index(after: typescript.startIndex)..<indexOfComma])
            let substring2 = String(typescript[secondIndex..<typescript.index(before: typescript.endIndex)])

            let type1 = try Type(typescript: substring1)
            let type2 = try Type(typescript: substring2)

            self = .tuple(type1, type2)
        } else if let generic = typescript.extractGenericType() {
            self = .generic(generic.name, try generic.associates.flatMap(Type.init(typescript:)))
        } else {
            self = .custom(typescript)
        }
    }
    
    public var swiftValue: String {
        switch self {
        case .any:
            return "Any"
        case .boolean:
            return "Bool"
        case .string:
            return "String"
        case .number:
            return "NSNumber"
        case .void:
            return "Void"
        case .swiftNumber(let swiftNum):
            return swiftNum.rawValue
        case .array(let type):
            return "[\(type.swiftValue)]"
        case .tuple(let type1, let type2):
            return "(\(type1.swiftValue), \(type2.swiftValue))"
        case .custom(let str):
            return str
        case .generic(let name, let associatedTypes):
            let associates = associatedTypes.map { $0.swiftValue }
                .joined(separator: ", ")
            return "\(name)<\(associates)>"
        }
    }
}

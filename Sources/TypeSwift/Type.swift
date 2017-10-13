//
//  Type.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 12/10/2017.
//

import Foundation

indirect enum Type: RawRepresentable, SwiftStringConvertible {
    case string
    case boolean
    case void
    case custom(String)
    case number(SwiftNumber)
    case array(Type)
    case tuple(Type, Type)
    
    var rawValue: String {
        switch self {
        case .string:
            return "string"
        case .boolean:
            return "boolean"
        case .void:
            return "void"
        case .custom(let customType):
            return customType
        case .number(let swiftNum):
            return "number/*\(swiftNum)*/"
        case .array(let type):
            return "Array<\(type.rawValue)>"
        case .tuple(let type1, let type2):
            return "[\(type1.rawValue), \(type2.rawValue)]"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "string" {
            self = .string
        } else if rawValue == "boolean" {
            self = .boolean
        } else if rawValue == "void" {
            self = .void
        } else if rawValue.hasPrefix("number") {
            guard rawValue.count > 8 else { return nil }

            let index = rawValue.index(rawValue.startIndex, offsetBy: 8)
            let suffix = String(rawValue.suffix(from: index))
            let swiftNumRaw = String(suffix.prefix(suffix.count - 2))
            guard let swiftNum = SwiftNumber(rawValue: swiftNumRaw) else {
                return nil
            }
            self = .number(swiftNum)
        } else if rawValue.hasPrefix("Array<") && rawValue.hasSuffix(">") {
            guard let idx = rawValue.index(of: "<") else { return nil }
            let start = rawValue.index(after: idx)
            let end = rawValue.index(rawValue.startIndex, offsetBy: rawValue.count - 1)

            let rawType = String(rawValue[start..<end])
            guard let type = Type(rawValue: rawType) else { return nil }
            self = .array(type)
        } else if rawValue.hasPrefix("[") && rawValue.hasSuffix("]") {

            var bracketsStartCount = 0
            var bracketsEndCount = 0

            var index: String.Index?

            for (idx, char) in rawValue.enumerated() {
                if char == "[" {
                    bracketsStartCount += 1
                } else if char == "]" {
                    bracketsEndCount += 1
                }
                
                if ((bracketsStartCount - bracketsEndCount) == 1) && char == "," {
                    index = rawValue.index(rawValue.startIndex, offsetBy: idx)
                    break
                }
            }
            
            guard let indexOfComma = index else {
                return nil
            }
 
            let spaceIndex = rawValue.index(after: indexOfComma)
            let secondIndex = rawValue.index(after: spaceIndex)

            let substring1 = String(rawValue[rawValue.index(after: rawValue.startIndex)..<indexOfComma])
            let substring2 = String(rawValue[secondIndex..<rawValue.index(before: rawValue.endIndex)])
            
            guard let type1 = Type(rawValue: substring1) else {
                return nil
            }
            
            guard let type2 = Type(rawValue: substring2) else {
                return nil
            }
            self = .tuple(type1, type2)
        } else {
            guard let firstChar = rawValue.first else { return nil }
            let isCapitalized = "\(firstChar)".lowercased() != "\(firstChar)"
            guard isCapitalized else {
                return nil
            }
            
            self = .custom(rawValue)
        }
    }
    
    var swiftValue: String {
        switch self {
        case .boolean:
            return "Bool"
        case .string:
            return "String"
        case .void:
            return "Void"
        case .number(let swiftNum):
            return swiftNum.rawValue
        case .array(let type):
            return "[\(type.swiftValue)]"
        case .tuple(let type1, let type2):
            return "(\(type1.swiftValue), \(type2.swiftValue))"
        case .custom(let str):
            return str
        }
    }
}

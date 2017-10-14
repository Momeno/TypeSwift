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
    case number
    case void
    case custom(String)
    case swiftNumber(SwiftNumber)
    case array(Type)
    case tuple(Type, Type)
    
    var rawValue: String {
        switch self {
        case .string:
            return TypeScript.Constants.string
        case .boolean:
            return TypeScript.Constants.boolean
        case .number:
            return TypeScript.Constants.number
        case .void:
            return TypeScript.Constants.void
        case .custom(let customType):
            return customType
        case .swiftNumber(let swiftNum):
            return "\(TypeScript.Constants.number)/*\(swiftNum)*/"
        case .array(let type):
            return "\(TypeScript.Constants.array)<\(type.rawValue)>"
        case .tuple(let type1, let type2):
            return "[\(type1.rawValue), \(type2.rawValue)]"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == TypeScript.Constants.string {
            self = .string
        } else if rawValue == TypeScript.Constants.boolean {
            self = .boolean
        } else if rawValue == TypeScript.Constants.void {
            self = .void
        } else if rawValue == TypeScript.Constants.number {
            self = .number
        } else if rawValue.hasPrefix(TypeScript.Constants.number) {
            guard rawValue.count > 8 else { return nil }

            let index = rawValue.index(rawValue.startIndex, offsetBy: 8)
            let suffix = String(rawValue.suffix(from: index))
            let swiftNumRaw = String(suffix.prefix(suffix.count - 2))
            guard let swiftNum = SwiftNumber(rawValue: swiftNumRaw) else {
                return nil
            }
            self = .swiftNumber(swiftNum)
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
        }
    }
}

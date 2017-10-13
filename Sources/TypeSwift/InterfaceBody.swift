//
//  InterfaceBody.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

struct InterfaceBody: RawRepresentable, SwiftStringConvertible {

    let rawValue: String
    let properties: [(name: String, type: String)]

    var swiftValue: String {
        return "{\n" + self.properties.map { name, type in
            return "\tvar \(name): \(type) { get }"
        }
        .joined(separator: "\n") + "\n}"
    }

    init?(rawValue: String) {
        guard let index = rawValue.index(of: "{") else { return nil }
        let start = rawValue.index(after: index)
        
        guard let end = rawValue.rangeOfCharacter(from: CharacterSet(charactersIn:"}"), options: .backwards, range: nil)?.lowerBound else {
            return nil
        }
        let workingString = rawValue[start..<end]
        let components = workingString.components(separatedBy: CharacterSet(charactersIn: "\n;"))
        var arr: [(String, String)] = []
        for element in components {
            if element.isEmpty { continue }
            
            let innerComponents = element.components(separatedBy: ":")
            
            guard innerComponents.count == 2 else {
                return nil
            }
            
            let first = innerComponents[0].trimmingCharacters(in: .whitespaces)
            let second = innerComponents[1].trimmingCharacters(in: .whitespaces)

            guard let type = Type(rawValue: second) else {
                return nil
            }

            arr.append((first, type.swiftValue))
        }
        self.properties = arr
        self.rawValue = rawValue
    }
}

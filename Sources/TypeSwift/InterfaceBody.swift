//
//  ModelBody.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

struct ModelBody: RawRepresentable, SwiftStringConvertible {

    let rawValue: String
    let properties: [(name: String, type: String)]

    var swiftValue: String {
        self.properties.map { name, type in
            return ""
        }
        return ""
    }

    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: CharacterSet(charactersIn: "\n;"))
        var arr: [(String, String)] = []
        for element in components {
            if element.isEmpty { continue }
            
            let innerComponents = element.components(separatedBy: ":")
            
            guard innerComponents.count == 2 else { return nil }
            
            let first = innerComponents[0].trimmingCharacters(in: .whitespaces)
            let second = innerComponents[1].trimmingCharacters(in: .whitespaces)
            arr.append((first, second))
        }
        self.properties = arr
        self.rawValue = rawValue
    }
}

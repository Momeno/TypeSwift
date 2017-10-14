//
//  Interface.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 14/10/2017.
//

import Foundation

struct Interface: RawRepresentable, SwiftStringConvertible {
    let interfaceDec: InterfaceDeclaration
    let name: String
    let body: InterfaceBody
    let rawValue: String
    
    var swiftValue: String {
        return "\(interfaceDec.swiftValue) \(name) \(body.swiftValue)"
    }
    
    init?(rawValue: String) {
        let working = rawValue
            .trimLeadingCharacters(in: .whitespacesAndNewlines)
            .trimTrailingCharacters(in: .whitespacesAndNewlines)
        
        guard let bodyRange = working.rangeOfBody() else {
            return nil
        }
        guard let body = InterfaceBody(rawValue: String(working[bodyRange])) else {
            return nil
        }
        guard let interfaceDec = working.interfaceDeclarationPrefix() else {
            return nil
        }
        
        let offsetedIndex = working.index(working.startIndex, offsetBy: interfaceDec.rawValue.count)
        let suffix = String(working.suffix(from: offsetedIndex))
        guard let indexOfSpace = suffix.index(of: " ") else {
            return nil
        }
        
        guard let name = String(suffix.suffix(from: indexOfSpace))
            .getWord(atIndex: 0, seperation: .whitespaces) else {
                
                return nil
        }
        
        self.interfaceDec = interfaceDec
        self.name = name
        self.body = body
        self.rawValue = rawValue
    }
}

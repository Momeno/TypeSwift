//
//  Function.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 17/10/2017.
//

import Foundation

struct FunctionDeclaration: SwiftStringConvertible, TypeScriptInitializable {

    let typescript: String
    let functionParams: [PropertyDefinition]
    var swiftValue: String {
        var str = self.typescript

        var function = "function"
        
        if let range = self.typescript.range(of: function) {
            str = str.replacingCharacters(in: range, with: "func")
        }
        
        var colon = ":"
        if let range = self.typescript.range(of: colon) {
            str = str.replacingCharacters(in: range, with: "->")
        }
        
        let regex = "\\(.*\\)"
        let paramString = functionParams.map {
            $0.swiftValue
        }
        .joined(separator: ", ")
        
        if let range = self.typescript.range(of: regex,
                                             options: .regularExpression,
                                             range: nil,
                                             locale: nil) {
            str = str.replacingCharacters(in: range, with: paramString)
        }

        return str
    }
    
    init(typescript: String) throws {
        self.typescript = typescript
    }
}

struct Function: TypeScriptInitializable, SwiftStringConvertible {
    
    let declaration: FunctionDeclaration
    let body: FunctionBody

    var swiftValue: String {
        return decla
    }

    init(typescript: String) throws {
        let body =
        self.swiftValue = type
    }
}

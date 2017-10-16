//
//  TypeScriptError.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur on 16/10/2017.
//

import Foundation

enum TypeScriptError: Swift.Error {
    case cannotDeclareNamespaceWithoutBody
    case cannotDeclareModuleWithoutBody
    case cannotDeclareInterfaceWithoutBody
    case cannotDeclareModelWithoutBody
    case invalidTypealias
    case invalidDeclaration(String)
    case typeScriptEmpty
    case unsupportedTypeScript(String)
}

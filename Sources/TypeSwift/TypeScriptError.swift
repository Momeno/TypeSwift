//
//  TypeScriptError.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur on 16/10/2017.
//

import Foundation

public enum TypeScriptError: Swift.Error {
    case cannotDeclareNamespaceWithoutBody
    case cannotDeclareModuleWithoutBody
    case cannotDeclareInterfaceWithoutBody
    case cannotDeclareModelWithoutBody
    case invalidTypealias
    case invalidFunctionDeclaration
    case invalidDeclaration(String)
    case typeScriptEmpty
    case unsupportedTypeScript(String)

    public var localizedDescription: String {
        switch self {
        case .cannotDeclareModelWithoutBody:
            return "cannotDeclareModelWithoutBody"
        case .cannotDeclareModuleWithoutBody:
            return "cannotDeclareModuleWithoutBody"
        case .cannotDeclareNamespaceWithoutBody:
            return "cannotDeclareNamespaceWithoutBody"
        case .cannotDeclareInterfaceWithoutBody:
            return "cannotDeclareInterfaceWithoutBody"
        case .invalidTypealias:
            return "invalidTypealias"
        case .invalidDeclaration(let str):
            return "invalidDeclaration(\(str))"
        case .unsupportedTypeScript(let str):
            return "unsupportedTypeScript(\(str))"
        case .typeScriptEmpty:
            return "typeScriptEmpty"
        case .invalidFunctionDeclaration:
            return "invalidFunctionDeclaration"
        }
    }
}

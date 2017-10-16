//
//  Protocols.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 12/10/2017.
//

import Foundation

protocol SwiftStringConvertible {
    var swiftValue: String { get }
}

protocol TypeScriptInitializable {
    init(typescript: String) throws
}

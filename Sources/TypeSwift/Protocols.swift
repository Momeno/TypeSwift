//
//  Protocols.swift
//  TypeSwiftPackageDescription
//
//  Created by Þorvaldur Rúnarsson on 12/10/2017.
//

import Foundation

public protocol SwiftStringConvertible {
    var swiftValue: String { get }
}

public protocol TypeScriptInitializable {
    init(typescript: String) throws
}

//
//  AccessLevel.swift
//  TypeSwift
//
//  Created by Þorvaldur Rúnarsson on 13/10/2017.
//

import Foundation

public enum PropertyAccessLevel: String, SwiftStringConvertible {
    case `public`
    case `private`
    case protected
    
    public var swiftValue: String {
        switch self {
        case .public:
            return "public"
        case .private:
            return "private"
        case .protected:
            return "internal"
        }
    }
}

public enum PropertyScope: String, SwiftStringConvertible {
    case `static`
    case none

    public var swiftValue: String {
        switch self {
        case .none:
            return ""
        default:
            return self.rawValue
        }
    }
    public var isStatic: Bool {
        return self.rawValue == PropertyScope.`static`.rawValue
    }
}

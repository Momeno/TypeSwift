import Foundation

public enum Language  {
    case swift
}

public struct TypeSwift {
    
    public static let sharedInstance = TypeSwift()
    
    public func convert(file: URL, to language: Language, output url: URL) throws {
        let typeScript = try loadTypeScript(from: file)
        switch language {
        case .swift:
            try typeScript.swiftValue
                .write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    public func convertedString(from typescript: String, to language: Language) throws -> String? {
        let typeScript = try loadTypeScript(from: typescript)
        switch language {
        case .swift:
            return typeScript.swiftValue
        }
    }
    
    private func loadTypeScript(from localURL: URL) throws -> TypeScript {
        let string = try String(contentsOf: localURL)
        return try loadTypeScript(from: string)
    }
    
    private func loadTypeScript(from string: String) throws -> TypeScript {
        return try TypeScript(typescript: string)
    }
}

import XCTest
@testable import TypeSwift

class TypeSwiftTests: XCTestCase {
    func testVariableType() {
        var variableType: VariableType? = VariableType(rawValue: "let")
        XCTAssert(variableType?.swiftValue == "var")

        variableType = VariableType(rawValue: "const")
        XCTAssert(variableType?.swiftValue == "let")

        variableType = VariableType(rawValue: "Gibberish")
        XCTAssertNil(variableType)
    }
    
    func testSwiftNumber() {
        var num = SwiftNumber(rawValue: "Float")
        XCTAssertNotNil(num)
        
        num = SwiftNumber(rawValue: "Double")
        XCTAssertNotNil(num)
        
        num = SwiftNumber(rawValue: "Int")
        XCTAssertNotNil(num)
        
        num = SwiftNumber(rawValue: "Gibberish")
        XCTAssertNil(num)
    }
    
    func testType() {
        var type: Type? = Type(rawValue: "boolean")
        XCTAssert(type?.swiftValue == "Bool")

        type = Type(rawValue: "number/*Float*/")
        XCTAssert(type?.swiftValue == "Float")
        
        type = Type(rawValue: "Array<number/*Float*/>")
        XCTAssert(type?.swiftValue == "Array<Float>")
        
        type = Type(rawValue: "Array<Array<boolean>>")
        XCTAssert(type?.swiftValue == "Array<Array<Bool>>")
        
        type = Type(rawValue: "[number/*Float*/, string]")
        XCTAssert(type?.swiftValue == "(Float, String)")
        
        type = Type(rawValue: "[number/*Float*/, [string, [number/*Int*/, boolean]]]")
        XCTAssert(type?.swiftValue == "(Float, (String, (Int, Bool)))")
        
        type = Type(rawValue: "[[string, [number/*Int*/, boolean]], number/*Float*/]")
        XCTAssert(type?.swiftValue == "((String, (Int, Bool)), Float)")
        
        type = Type(rawValue: "CustomType")
        XCTAssert(type?.swiftValue == "CustomType")
        
        type = Type(rawValue: "customType")
        XCTAssertNil(type)
    }

    static var allTests = [
        ("testVariableDeclaration", testVariableType),
        ("testSwiftNumber", testSwiftNumber),
        ("testType", testType)
    ]
}

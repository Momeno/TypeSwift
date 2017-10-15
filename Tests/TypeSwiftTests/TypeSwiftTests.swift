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

        type = Type(rawValue: "number")
        XCTAssert(type?.swiftValue == "NSNumber")
        
        type = Type(rawValue: "number/*Float*/")
        XCTAssert(type?.swiftValue == "Float")
        
        type = Type(rawValue: "Array<number/*Float*/>")
        XCTAssert(type?.swiftValue == "[Float]")
        
        type = Type(rawValue: "Array<Array<boolean>>")
        XCTAssert(type?.swiftValue == "[[Bool]]")
        
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
    
    func testModelDeclaration() {
        var dec = ModelDeclaration(rawValue: "class")
        XCTAssert(dec?.swiftValue == "struct")

        dec = ModelDeclaration(rawValue: "Gibberish")
        XCTAssertNil(dec)
    }
    
    func testInterfaceDeclaration() {
        var dec = InterfaceDeclaration(rawValue: "export interface")
        XCTAssert(dec?.swiftValue == "public protocol")
        
        dec = InterfaceDeclaration(rawValue: "interface")
        XCTAssert(dec?.swiftValue == "protocol")
        
        dec = InterfaceDeclaration(rawValue: "gibberish")
        XCTAssertNil(dec)
    }
    
    func testInterfaceBody() {
        var body = InterfaceBody(rawValue: "{readonly person: [string, House]\n\treadonly street: number/*UInt*/; readonly number: number/*UInt*/ }")
        var expected = "{\n\tvar person: (String, House) { get }\n\tvar street: UInt { get }\n\tvar number: UInt { get }\n}"
        XCTAssert(body?.swiftValue == expected)
        
        var raw = """
        {
        \tpeople: Array<[number, Person]>;
        \treadonly street? : number/*UInt*/
        \tnumber: number
        }
        """
        body = InterfaceBody(rawValue: raw)
        expected = """
        {
        \tvar people: [(NSNumber, Person)] { get set }
        \tvar street: UInt? { get }
        \tvar number: NSNumber { get set }
        }
        """
        
        XCTAssert(body?.swiftValue == expected)
        
        raw = """
        {
        \tpeople: Array<[numbers, Person]>;
        \tstreet: number/*UInt*/
        \tnumber: number
        }
        """
        XCTAssertNil(InterfaceBody(rawValue: raw))
        
    }
    
    func testAccessLevel() {
        var access = PropertyAccessLevel(rawValue: "private")
        XCTAssert(access?.swiftValue == "private")
        
        access = PropertyAccessLevel(rawValue: "public")
        XCTAssert(access?.swiftValue == "public")

        access = PropertyAccessLevel(rawValue: "export")
        XCTAssertNil(access)
    }
    
    func testPropertyDefinition() {
        var property = PropertyDefinition(rawValue: "string: string")
        XCTAssert(property?.swiftValue == "string: String")

        property = PropertyDefinition(rawValue: "name:[string, number]")
        XCTAssert(property?.swiftValue == "name: (String, NSNumber)")
        
        property = PropertyDefinition(rawValue: "optional?: [boolean, Array<number/*Int*/>]")
        XCTAssert(property?.swiftValue == "optional: (Bool, [Int])?")
        
        property = PropertyDefinition(rawValue: "optional? string")
        XCTAssertNil(property)
    }
    
    func testModelBody() {
        var raw = """
          class Some {
        \tprotected readonly people: Array<[number, Person]>
        \tprivate street: number/*UInt*/
        \tpublic number: number
        }
        """
        let exp = """
        {
        \tinternal let people: [(NSNumber, Person)]
        \tprivate var street: UInt
        \tpublic var number: NSNumber
        }
        """
        var body = ModelBody(rawValue: raw)
        XCTAssert(body?.swiftValue == exp)
        
        raw = "{protected readonly people :Array<[number, Person]>;private street: number/*UInt*/;public number: NSNumber}"
        body = ModelBody(rawValue: raw)
        XCTAssert(body?.swiftValue == exp)
    }
    
    func testInterface() {
        var raw = """
        interface Bar {
        \treadonly x: number
        }
        """
        
        let exp = """
        protocol Bar {
        \tvar x: NSNumber { get }
        }
        """
        var interface = Interface(rawValue: raw)
        XCTAssert(interface?.swiftValue == exp)
        
        raw = """
        class Bar {
        readonly y: number
        }
        """
        interface = Interface(rawValue: raw)
        XCTAssertNil(interface)
    }
    
    func testModel() {
        var raw = """
        class Foo: Interface {
        \tpublic readonly x: number;
        \tprivate y: number;
        }
        """
        
        let exp = """
        struct Foo: Interface {
        \tpublic let x: NSNumber
        \tprivate var y: NSNumber
        }
        """
        var interface = Model(rawValue: raw)
        XCTAssert(interface?.swiftValue == exp)
        
        raw = """
        protocol Bar {
        readonly x: number
        }
        """
        interface = Model(rawValue: raw)
        XCTAssertNil(interface)
    }
    
    func testTypeScript() {
        let raw = """
        interface Bar {
        \treadonly x: number
        }

        class Foo {
        \tpublic readonly x: number;
        \tprivate y: number;
        } class Bar {
        \tprotected property : Array<[boolean, string]>
        }
        """
        
        let exp = """
        protocol Bar {
        \tvar x: NSNumber { get }
        }

        struct Foo {
        \tpublic let x: NSNumber
        \tprivate var y: NSNumber
        }

        struct Bar {
        \tinternal var property: [(Bool, String)]
        }
        """

        XCTAssert(TypeScript(rawValue: raw)?.swiftValue == exp)
    }

    func testStringTrimHelpers() {
        var str = "    s d fja    "
        var exp = "    s d fja"
        XCTAssert(str.trimTrailingWhitespace() == exp)
        
        str = exp.trimLeadingWhitespace()
        exp = "s d fja"
        XCTAssert(str == exp)
        
        str = " © "
        exp = "©"
        XCTAssert(str.trimLeadingWhitespace().trimTrailingWhitespace() == exp)
        
        str = " 😘 "
        exp = "😘"
        XCTAssert(str.trimTrailingWhitespace().trimLeadingWhitespace() == exp)
        str = " 👨‍👩‍👧‍👧 "
        exp = "👨‍👩‍👧‍👧"
        XCTAssert(str.trimTrailingWhitespace().trimLeadingWhitespace() == exp)
    }
    
    func testStringPrefixHelpers() {
        var test = "    interface Some {"
        XCTAssert(test.interfaceDeclarationPrefix()?.rawValue == "interface")
        XCTAssertNil(test.modelDeclarationPrefix())
        
        test = "    export interface Some {"
        XCTAssertNotNil(test.interfaceDeclarationPrefix()?.rawValue == "export interface")
        XCTAssertNil(test.modelDeclarationPrefix())
        
        test = "\t  \t class Some {"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssertNotNil(test.modelDeclarationPrefix())
        
        test = "\t  export class Some {"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssert(test.modelDeclarationPrefix()?.rawValue == "export class")
        
        test = "class Foo"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssert(test.modelDeclarationPrefix()?.rawValue == "class")
        
        test = "export inter"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssertNil(test.modelDeclarationPrefix())
    }
    
    func testStringBodyHelpers() {
        var test = "{ { } }  }"
        var exp = "{ { } }"
        XCTAssert(String(test[test.rangeOfBody()!]) == exp)
        
        test = "{\n{ } } class bla {  }"
        exp = "{\n{ } }"
        XCTAssert(String(test[test.rangeOfBody()!]) == exp)
        
        test = "{} }   "
        let notExp = "{} }"
        XCTAssertFalse(notExp == String(test[test.rangeOfBody()!]))
    }
    
    static var allTests = [
        ("testVariableDeclaration", testVariableType),
        ("testSwiftNumber", testSwiftNumber),
        ("testType", testType),
        ("testModelDeclaration", testModelDeclaration),
        ("testInterfaceDeclaration", testInterfaceDeclaration),
        ("testInterfaceBody", testInterfaceBody),
        ("testAccessLevel", testAccessLevel),
        ("testModelBody", testModelBody),
        ("testModel", testModel),
        ("testInterface", testInterface),
        ("testTypeScript", testTypeScript),
        ("testPropertyDefinition", testPropertyDefinition),
        ("testStringTrimHelpers", testStringTrimHelpers),
        ("testStringPrefixHelpers", testStringPrefixHelpers)
    ]
}

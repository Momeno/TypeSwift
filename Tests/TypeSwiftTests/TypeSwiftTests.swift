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
        var type: Type? = try! Type(typescript: "boolean")
        XCTAssert(type?.swiftValue == "Bool")

        type = try! Type(typescript: "number")
        XCTAssert(type?.swiftValue == "NSNumber")
        
        type = try! Type(typescript: "number/*Float*/")
        XCTAssert(type?.swiftValue == "Float")
        
        type = try! Type(typescript: "Array<number/*Float*/>")
        XCTAssert(type?.swiftValue == "[Float]")
        
        type = try! Type(typescript: "Array<Array<boolean>>")
        XCTAssert(type?.swiftValue == "[[Bool]]")
        
        type = try! Type(typescript: "[number/*Float*/, string]")
        XCTAssert(type?.swiftValue == "(Float, String)")
        
        type = try! Type(typescript: "[number/*Float*/, [string, [number/*Int*/, boolean]]]")
        XCTAssert(type?.swiftValue == "(Float, (String, (Int, Bool)))")
        
        type = try! Type(typescript: "[[string, [number/*Int*/, boolean]], number/*Float*/]")
        XCTAssert(type?.swiftValue == "((String, (Int, Bool)), Float)")
        
        type = try! Type(typescript: "CustomType")
        XCTAssert(type?.swiftValue == "CustomType")
        
        type = try? Type(typescript: "customType")
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
        var body = try! InterfaceBody(typescript: "{readonly person: [string, House]\n\treadonly street: number/*UInt*/; readonly number: number/*UInt*/ }")
        var expected = "{\nvar person: (String, House) { get }\nvar street: UInt { get }\nvar number: UInt { get }\n}"
        XCTAssert(body.swiftValue == expected)
        
        var raw = """
        {
        people: Array<[number, Person]>;
        readonly street? : number/*UInt*/
        number: number
        }
        """
        body = try! InterfaceBody(typescript: raw)
        expected = """
        {
        var people: [(NSNumber, Person)] { get set }
        var street: UInt? { get }
        var number: NSNumber { get set }
        }
        """
        
        XCTAssert(body.swiftValue == expected)
        
        raw = """
        {
        people: Array<[numbers, Person]>;
        street: number/*UInt*/
        number: number
        }
        """
        XCTAssertNil(try? InterfaceBody(typescript: raw))
        
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
        var property: PropertyDefinition? = try! PropertyDefinition(typescript: "string: string")
        XCTAssert(property?.swiftValue == "string: String")

        property = try! PropertyDefinition(typescript: "name:[string, number]")
        XCTAssert(property?.swiftValue == "name: (String, NSNumber)")
        
        property = try! PropertyDefinition(typescript: "optional?: [boolean, Array<number/*Int*/>]")
        XCTAssert(property?.swiftValue == "optional: (Bool, [Int])?")
        
        property = try? PropertyDefinition(typescript: "optional? string")
        XCTAssertNil(property)
    }
    
    func testModelBody() {
        var raw = """
          class Some {
        protected readonly people: Array<[number, Person]>
        private static street: number/*UInt*/
        public number: number
        }
        """
        let exp = """
        {
        internal let people: [(NSNumber, Person)]
        private static var street: UInt
        public var number: NSNumber
        }
        """
        var body = try! ModelBody(typescript: raw)
        XCTAssert(body.swiftValue == exp)
        
        raw = "{protected readonly people :Array<[number, Person]>;private static street: number/*UInt*/;public number: NSNumber}"
        body = try! ModelBody(typescript: raw)
        XCTAssert(body.swiftValue == exp)
    }
    
    func testInterface() {
        var raw = """
        interface Bar {
        readonly x: number
        }
        """
        
        let exp = """
        protocol Bar {
        var x: NSNumber { get }
        }
        """
        var interface: Interface? = try! Interface(typescript: raw)
        XCTAssert(interface?.swiftValue == exp)
        
        raw = """
        class Bar {
        readonly y: number
        }
        """
        interface = try? Interface(typescript: raw)
        XCTAssertNil(interface)
    }
    
    func testModel() {
        var raw = """
        export class Foo implements Interface {
        public readonly x: number;
        private y: number;
        }
        """
        
        let exp = """
        public struct Foo: Interface {
        public let x: NSNumber
        private var y: NSNumber
        }
        """
        var model: Model? = try! Model(typescript: raw)
        XCTAssert(model?.swiftValue == exp)
        
        raw = """
        protocol Bar {
        readonly x: number
        }
        """
        model = try? Model(typescript: raw)
        XCTAssertNil(model)
    }
    
    func testTypeScript() {
        let raw = """
        type T = Array<number/*UInt*/>
        module Module {
        type V = [string, number]
        namespace NameSpace {
        interface Bar {
        readonly x: number
        }
        }
        }
        class Foo {
        public readonly x: number;
        private y: number;
        } class Bar {
        protected property : Array<[boolean, string]>
        }
        """
        
        let exp = """
        typealias T = [UInt]
        struct Module {
        typealias V = (String, NSNumber)
        struct NameSpace {
        protocol Bar {
        var x: NSNumber { get }
        }
        }
        }
        struct Foo {
        public let x: NSNumber
        private var y: NSNumber
        }
        struct Bar {
        internal var property: [(Bool, String)]
        }
        """

        XCTAssert((try! TypeScript(typescript: raw)).swiftValue == exp)
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

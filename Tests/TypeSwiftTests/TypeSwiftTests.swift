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

        type = try! Type(typescript: "Dictionary<UserID, DistributedModel<boolean>>")
        XCTAssert(type?.swiftValue == "Dictionary<UserID, DistributedModel<Bool>>")
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

        property = try? PropertyDefinition(typescript: "someVar: string = `string ${SomeClass.someStaticVar}`")
        var exp = "someVar: String = \"string \\(SomeClass.someStaticVar)\""
        XCTAssert(property?.swiftValue == exp)

        property = try? PropertyDefinition(typescript: "reference = DatabaseReference.devices")
        exp = "reference = DatabaseReference.devices"
        XCTAssert(property?.swiftValue == exp)
    }
    
    func testModelBody() {
        var raw = """
          class Some {
        protected readonly people: Array<[number, Person]>
        private static street: number/*UInt*/
        public number?: number
        }
        """
        let exp = """
        {
        internal let people: [(NSNumber, Person)]
        private static var street: UInt
        public var number: NSNumber?
        init(_ people: [(NSNumber, Person)], _ number: NSNumber?) {
        self.people = people
        self.number = number
        }
        public init(people: [(NSNumber, Person)], number: NSNumber?) {
        self.people = people
        self.number = number
        }
        }
        """
        var body = try! ModelBody(typescript: raw)
        XCTAssert(body.swiftValue == exp)
        
        raw = "{protected readonly people :Array<[number, Person]>;private static street: number/*UInt*/;public number: NSNumber?}"
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
        export class Foo extends Another implements Interface, SomeOther {
        public readonly x: number;
        private y: number;
        someFunc(): string {
        return 'some string'
        }
        }
        """
        
        let exp = """
        public struct Foo: Another, Interface, SomeOther {
        public let x: NSNumber
        private var y: NSNumber
        init(_ x: NSNumber, _ y: NSNumber) {
        self.x = x
        self.y = y
        }
        public init(x: NSNumber, y: NSNumber) {
        self.x = x
        self.y = y
        }
        public func someFunc()-> String {
        return \"some string\"
        }
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

    func testCodeBlock() {
        let body = try! CodeBlock(typescript: """
        {
        return `/path/to/${userID}/${dialogID}`
        }
        """)

        let exp = """
        {
        return \"/path/to/\\(userID)/\\(dialogID)\"
        }
        """

        XCTAssert(body.swiftValue == exp)

        // currently this model init method doesn't fail

    }

    func testFunction() {
        let function = try! Function(typescript: """
        function getReference(dialogID: string, userID: number/*UInt*/) : string {
        return `/path/to/${userID}/${dialogID}`
        }
        """)

        let exp = "public func getReference(dialogID: String, userID: UInt) -> String {\nreturn \"/path/to/\\(userID)/\\(dialogID)\"\n}"
        XCTAssert(function.swiftValue == exp)
    }
    
    func testTypeScript() {
        let raw = """
        import {
          UserId,
          DeviceId,
          GameId,
          ChatDialogId,
          BalrogEnum,
          BalrogRawReprisentable,
        } from './InterfacesAndIds'
        // Some comment
        type T = Array<number/*UInt*/>
        module Module {
        type V = [string, number]
        namespace NameSpace {
        interface Bar {
        readonly x: number
        }
        }
        function some(userID: string) : string {
        return `something/${userID}`
        }
        }
        export default class Foo {
        public readonly x: number;
        private y: number;
        } export class Bar {
        protected property : Array<[boolean, string]>
        }
        class FooBar {
        static some = \"some\"
        static other = new Comment("")
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
        public func some(userID: String) -> String {
        return \"something/\\(userID)\"
        }
        }
        public struct Foo {
        public let x: NSNumber
        private var y: NSNumber
        init(_ x: NSNumber, _ y: NSNumber) {
        self.x = x
        self.y = y
        }
        public init(x: NSNumber, y: NSNumber) {
        self.x = x
        self.y = y
        }
        }
        public struct Bar {
        internal var property: [(Bool, String)]
        init(_ property: [(Bool, String)]) {
        self.property = property
        }
        public init(property: [(Bool, String)]) {
        self.property = property
        }
        }
        struct FooBar {
        public static var some = \"some\"
        public static var other = Comment("")

        }
        """

        XCTAssert((try! TypeScript(typescript: raw)).swiftValue == exp)
    }

    func testBigTest() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        let url = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent("models")
            .appendingPathComponent("parsebleModels")
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!

        while let element = enumerator.nextObject() as? String {
            guard element.hasSuffix(".ts") else { continue }
            do {
                let data = try Data(contentsOf: url.appendingPathComponent(element))
                let str = String(data: data, encoding: .utf8)
                do {
                    let ts = try TypeScript(typescript: str!)
                    let swift = ts.swiftValue
                    XCTAssert(swift.isEmpty == false)
                    try swift.write(to: url.appendingPathComponent(element.replacingOccurrences(of: ".ts", with: ".swift")),
                                atomically: true,
                                encoding: .utf8)
                } catch {
                    print(error.localizedDescription)
                    print("")
                }
            } catch {
                print("Error: \n\(error.localizedDescription)")
            }
        }
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
        ("testFunction", testFunction),
        ("testCodeBlock", testCodeBlock),
        ("testInterface", testInterface),
        ("testTypeScript", testTypeScript),
        ("testPropertyDefinition", testPropertyDefinition)
    ]
}

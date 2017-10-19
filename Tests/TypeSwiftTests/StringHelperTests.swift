//
//  StringHelperTests.swift
//  TypeSwiftTests
//
//  Created by Þorvaldur Rúnarsson on 19/10/2017.
//

import XCTest
@testable import TypeSwift

class StringHelperTests: XCTestCase {
    
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
        
        test = "\t  export default class Some {"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssert(test.modelDeclarationPrefix()?.rawValue == "export default class")
        
        test = "class Foo"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssert(test.modelDeclarationPrefix()?.rawValue == "class")
        
        test = "export inter"
        XCTAssertNil(test.interfaceDeclarationPrefix())
        XCTAssertNil(test.modelDeclarationPrefix())
    }
    
    func testStringTrimComments() {
        let str = """
        æadfjs kdfa fdlæakfkjdaldkf/* aædflkja kækasd */
        fd sj lfdasæ// lfdkaæ jkldf/*
        Some number/*UInt*/
        """
        
        let exp = """
        æadfjs kdfa fdlæakfkjdaldkf
        fd sj lfdasæ
        Some number/*UInt*/
        """
        
        XCTAssert(str.trimComments() == exp)
    }
    
    func testTypeScriptStringFormatRegex() {
        var str = """
        {
        return \"/path/to/${userID}/${dialogID}\"
        }
        """
        XCTAssert(String(str[str.rangeOfTypeScriptFormatString()!]) == "\"/path/to/${userID}/${dialogID}\"")
        
        
        str = "\" as s dad ${some} \\\" sjxkæajdk a\""
        XCTAssert(str.isTypeScriptFormatString)
        
        str = """
        \" as s dad ${some} \\\" sjxkæajdk a\\\"\"
        """
        XCTAssert(str.isTypeScriptFormatString)
        
        str = """
        \"/path/to/${userID}/${dialogID}\"
        """
        str = "regular string \\\"  \""
        
        XCTAssertFalse(str.isTypeScriptFormatString)
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
    
    func testImportRegex() {
        var str = """
        import DatabaseReference from './Refrences'
        dfafdasf
        import DatabaseReference from "./Refrences"

        fdsa
        """
        
        let importStr = """
        import {
          UserId,
          DeviceId,
          GameId,
          ChatDialogId,
          BalrogEnum,
          BalrogRawReprisentable,
        } from './InterfacesAndIds'
        """
        
        XCTAssert(String(str[str.rangeOfImport()!]) == "import DatabaseReference from './Refrences'")
        str = """
        ældkfj aklf dfa jkfldjfw slkfs klj fa
        dlsa jfldkj d djlsk
        
        faasfdf
        \(importStr)
        
        
        fdaads fkl dajkl klfads jadsk jfadsklj dfa kjaadkf adf
        adfdfkls jaædsklj fs djkjd sfkldjaf a kfads klæ adfssxkæ jadfs
        ads dklfs jkadsj fkljads fla
        fasdfadlkjf adkæljf jæaldæj fad
        """
        
        XCTAssert(str[str.rangeOfImport()!] == importStr)
    }
    
    func testExtractAssociatedType() {
        var str = "Dictionary<UserID, DistributedModel<PublicProfile>>"
        var exp = [
            "UserID",
            "DistributedModel<PublicProfile>"
        ]
        XCTAssert(str.extractGenericType()!.associates == exp && str.extractGenericType()!.name == "Dictionary")
        
        str = "DistributedModel<PublicProfile>"
        exp = [
            "PublicProfile"
        ]
        XCTAssert(str.extractGenericType()!.associates == exp && str.extractGenericType()!.name == "DistributedModel")
    }
    
    static var allTests = [
        ("testStringTrimHelpers", testStringTrimHelpers),
        ("testStringPrefixHelpers", testStringPrefixHelpers),
        ("testTypeScriptStringFormatRegex", testTypeScriptStringFormatRegex),
        ("testStringTrimComments", testStringTrimComments),
        ("testStringBodyHelpers", testStringBodyHelpers),
        ("testImportRegex", testImportRegex),
        ("testExtractAssociatedType", testExtractAssociatedType)
    ]
}

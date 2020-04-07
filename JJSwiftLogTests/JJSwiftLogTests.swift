//
//  JJSwiftLogTests.swift
//  JJSwiftLogTests
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJ. All rights reserved.
//

import XCTest
@testable import JJSwiftLog

class JJSwiftLogTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJJLogOutput() {
        XCTAssertTrue(JJLogOutputConfig.fileNameOfFile("/test/test.suffix") == "test.suffix")
        XCTAssertTrue(JJLogOutputConfig.fileNameOfFile("/test/test") == "test")
        XCTAssertTrue(JJLogOutputConfig.fileNameOfFile("/test/") == "")
        XCTAssertTrue(JJLogOutputConfig.fileNameOfFile("/test") == "test")
        XCTAssertTrue(JJLogOutputConfig.fileNameOfFile("") == "")
        
        XCTAssertTrue(JJLogOutputConfig.fileNameWithoutSuffix("/test/test.suffix") == "test")
        XCTAssertTrue(JJLogOutputConfig.fileNameWithoutSuffix("/test/test") == "test")
        XCTAssertTrue(JJLogOutputConfig.fileNameWithoutSuffix("/test/") == "")
        XCTAssertTrue(JJLogOutputConfig.fileNameWithoutSuffix("") == "")
    }

}

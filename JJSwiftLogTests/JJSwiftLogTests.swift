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
    
    func testLogFormat() {
//        JJLogFormatter.shared.formatLog("")
//        XCTAssertTrue(JJLogFormatter.shared.segments.isEmpty)
        
        JJLogFormatter.shared.formatLog("1")
        XCTAssert(JJLogFormatter.shared.segments.count == 1)
        
        JJLogFormatter.shared.formatLog("%M")
        XCTAssert(JJLogFormatter.shared.segments.count == 2)
    }
    
    class Filter1: JJLogFilter {
        func ignore(log: JJLogEntity, message: String) -> Bool {
            return log.message == "123"
        }
    }
    
    class Filter2: JJLogFilter {
        func ignore(log: JJLogEntity, message: String) -> Bool {
            return false
        }
    }
    
    class CustomerFilterLog: JJLogObject {
        override func output(log: JJLogEntity, message: String) {
            XCTAssertTrue(log.message == "456")
        }
    }
    
    func testLogFilters() {
        let customtLog = CustomerFilterLog(identifier: "test1", delegate: nil)
        customtLog.filters = [Filter1(), Filter2()]
        JJLogger.addLogOutput(customtLog)
        
        JJLogger.debug("123")
        JJLogger.debug("456")
    }

}

//
//  FormatterTests.swift
//  JJSwiftLogTests
//
//  Created by Jezz on 2022/2/6.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import XCTest
@testable import JJSwiftLog

class FormatterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    class Formatter1: JJLogFormatterProtocol {
        func format(log: JJLogEntity, message: String) -> String {
            return "123" + message
        }
    }
    
    class Formatter2: JJLogFormatterProtocol {
        func format(log: JJLogEntity, message: String) -> String {
            return message + "456"
        }
    }
    
    class CustomerFormatterLog: JJLogObject {
        override func output(log: JJLogEntity, message: String) {
            XCTAssertTrue(message.hasPrefix("123"))
            XCTAssertTrue(message.hasSuffix("456"))
        }
    }
    
    func testFormatter() {
        let customtLog = CustomerFormatterLog(identifier: "CustomerFilterLog", delegate: nil)
        customtLog.formatters = [Formatter1(), Formatter2()]
        JJLogger.addLogOutput(customtLog)
        
        JJLogger.debug("any")
    }
    
    class Formatter3: JJLogFormatterProtocol {
        func format(log: JJLogEntity, message: String) -> String {
            return ""
        }
    }
    
    class CustomerFormatterLog1: JJLogObject {
        override func output(log: JJLogEntity, message: String) {
            XCTAssertTrue(message == "")
        }
    }
    
    func testEmptyFormatter() {
        let customtLog = CustomerFormatterLog1(identifier: "CustomerFilterLog1", delegate: nil)
        customtLog.formatters = [Formatter3()]
        JJLogger.addLogOutput(customtLog)
        
        JJLogger.debug("any")
    }
    
    class Formatter4: JJLogFormatterProtocol {
        func format(log: JJLogEntity, message: String) -> String {
            return "123"
        }
    }
    
    class CustomerFormatterLog2: JJLogObject {
        override func output(log: JJLogEntity, message: String) {
            XCTAssertTrue(message == "123")
        }
    }
    
    func testReplaceFormatter() {
        let customtLog = CustomerFormatterLog2(identifier: "CustomerFilterLog2")
        customtLog.formatters = [Formatter4()]
        JJLogger.addLogOutput(customtLog)
        
        JJLogger.debug("any")
    }

}

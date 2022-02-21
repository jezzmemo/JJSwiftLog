//
//  SentryTests.swift
//  JJSwiftLogTests
//
//  Created by Jezz on 2022/2/20.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import XCTest
import JJSwiftLog

class SentryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSentryFailure() throws {
        let expectation = XCTestExpectation(description: "Chops the vegetables")

        let sentry = JJSentryOutput(sentryKey: "124", sentryURL: URL(string: "https://www.baidu.com")!)
        sentry.failure = { _ in
            expectation.fulfill()
        }
        JJLogger.addLogOutput(sentry)
        JJLogger.info("any")
        wait(for: [expectation], timeout: 5)

    }

}

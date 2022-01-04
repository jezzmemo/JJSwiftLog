//
//  JJLogMeta.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/1/2.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// Log object
public struct JJLogEntity {
    
    /// Log level
    public var level: JJSwiftLog.Level

    /// Date
    public var date: Date
    
    /// Message
    public var message: String
    
    /// Function name
    public var functionName: String
    
    /// File name
    public var fileName: String
    
    /// Line number
    public var lineNumber: Int
    
    /// Extra info
    public var extraInfo: [String: Any]
    
    /// Init
    /// - Parameters:
    ///   - level: Log level
    ///   - date: Send time
    ///   - message: Message
    ///   - functionName: Function
    ///   - fileName: File
    ///   - lineNumber: Line
    ///   - extraInfo: Extra info
    public init(level: JJSwiftLog.Level, date: Date, message: String, functionName: String, fileName: String, lineNumber: Int, extraInfo: [String: Any] = [:]) {
        self.level = level
        self.date = date
        self.message = message
        self.functionName = functionName
        self.fileName = fileName
        self.lineNumber = lineNumber
        self.extraInfo = extraInfo
    }
}

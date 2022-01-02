//
//  JJLogMeta.swift
//  JJSwiftLog
//
//  Created by Jezz on 2022/1/2.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// Message object
public struct JJLogBody {
    
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
    ///   - message: Message
    ///   - functionName: Function
    ///   - fileName: File
    ///   - lineNumber: Line
    ///   - extraInfo: Extra info
    public init(message: String, functionName: String, fileName: String, lineNumber: Int, extraInfo: [String: Any] = [:]) {
        self.message = message
        self.functionName = functionName
        self.fileName = fileName
        self.lineNumber = lineNumber
        self.extraInfo = extraInfo
    }
}

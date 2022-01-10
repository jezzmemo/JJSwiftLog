//
//  JJLogObject.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/1/7.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// Log base class object
///
/// Extend form JJLogOutput, define the basic field and method
open class JJLogObject: JJLogOutput {
    
    open var logLevel: JJSwiftLog.Level = .debug
    
    open var queue: DispatchQueue?
    
    open var identifier: String
    
    open var formatter: JJLogFormatterProtocol?
    
    public weak var delegate: JJLogOutputDelegate?
    
    open var filter: JJLogFilter?
    
    public init(identifier: String = "", delegate: JJLogOutputDelegate? = nil) {
        self.identifier = identifier
        self.delegate = delegate
    }
    
    open func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) {
        let message = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        let log = JJLogEntity(level: level, date: Date(), message: msg, functionName: function, fileName: file, lineNumber: line)
        if self.filter?.ignore(log: log) == true {
            return
        }
        let formatMessage = self.formatter?.format(log: log)
        
        self.output(log: log, message: formatMessage != nil ? formatMessage! : message)
    }
    
    /// Output message and origin log object
    /// - Parameters:
    ///   - log: JJLogEntity
    ///   - message: Format message
    open func output(log: JJLogEntity, message: String) {
        fatalError("Must Override")
    }
    
}

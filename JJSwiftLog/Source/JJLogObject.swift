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
    
    /// Log level, default value is `.debug`
    open var logLevel: JJSwiftLog.Level = .debug
    
    /// Log queue
    open var queue: DispatchQueue?
    
    /// Log object identifier, will be unique
    open var identifier: String
    
    /// Log format protocol, option
    open var formatter: JJLogFormatterProtocol?
    
    /// Log object forward internal information to outside
    public weak var delegate: JJLogOutputDelegate?
    
    /// Log filter
    open var filter: JJLogFilter?
    
    /// Init JJLogObject
    /// - Parameters:
    ///   - identifier: unique identifier
    ///   - delegate: internal callback
    public init(identifier: String = "", delegate: JJLogOutputDelegate? = nil) {
        self.identifier = identifier
        self.delegate = delegate
    }
    
    open func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) {
        let log = JJLogEntity(level: level, date: Date(), message: msg, functionName: function, fileName: file, lineNumber: line)
        
        // Format log message
        let message = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        let formatMessage = self.formatter?.format(log: log, message: message)
        
        // Weather ignore log
        if self.filter?.ignore(log: log, message: formatMessage ?? message) == true {
            return
        }
        
        self.output(log: log, message: formatMessage ?? message)
    }
    
    /// Output format message and log object
    /// - Parameters:
    ///   - log: JJLogEntity
    ///   - message: Format message
    open func output(log: JJLogEntity, message: String) {
        fatalError("Must Override")
    }
    
}

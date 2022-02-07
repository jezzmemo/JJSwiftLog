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
    
    /// Log object forward internal information to outside
    public weak var delegate: JJLogOutputDelegate?
    
    /// Log format array protocol, option
    open var formatters: [JJLogFormatterProtocol]?
    
    /// Log array filter
    open var filters: [JJLogFilter]?
    
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
        
        /// ------------- Deprecated method ---------------------
        // Weather to ignore logs
        if self.filter?.ignore(log: log, message: message) == true {
            return
        }
        
        let formatMessage = self.formatter?.format(log: log, message: message)
        /// ------------- Deprecated method ---------------------
        
        /// Formatter and filter collection
        if let filters = self.filters {
            for filter in filters {
                if filter.ignore(log: log, message: message) == true {
                    return
                }
            }
        }
        
        var formatResult = message
        self.formatters?.forEach({ formatter in
            formatResult = formatter.format(log: log, message: formatResult)
        })
        
        /// formatters override formatter
        ///
        /// formatters is higher priority than formatter
        self.output(log: log, message: formatMessage == nil ? formatResult : formatMessage!)
    }
    
    /// Output format message and log object
    /// - Parameters:
    ///   - log: JJLogEntity
    ///   - message: Format message
    open func output(log: JJLogEntity, message: String) {
        fatalError("Must Override")
    }
    
    // MARK: - Deprecated
    
    /// Log format protocol, option
    @available(*, deprecated, message: "Please use formatters property")
    open var formatter: JJLogFormatterProtocol?
    
    /// Log filter
    @available(*, deprecated, message: "Please use filters property")
    open var filter: JJLogFilter?
    
}

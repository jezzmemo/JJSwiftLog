//
//  JJLogOutput.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// Constant value
internal struct JJLogOutputConfig {
    
    static let padding = " "
    
    static let dateTimezoneformatter = "yyyy-MM-dd HH:mm:ss.SSSZ"

    static let timeFormatter = "HH:mm:ss"

    static let dateFormatter = "yyyy-MM-dd"
    
    static let formatDate = DateFormatter()
    
    static let newline = "\n"
    
    static let point = "."
    
    /// Get file name from file string
    /// - Parameter file: File path
    static func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }
    
    /// Get file name with out suffix
    /// - Parameter file: File path
    static public func fileNameWithoutSuffix(_ file: String) -> String {
        let fileName = fileNameOfFile(file)

        if !fileName.isEmpty {
            let fileNameParts = fileName.components(separatedBy: ".")
            if let firstPart = fileNameParts.first {
                return firstPart
            }
        }
        return ""
    }
}

/// JJLogOutput callback
public protocol JJLogOutputDelegate: AnyObject {
    
    /// SDK special log message
    func internalLog(source: JJLogOutput, log: JJLogEntity)
}

/// Abstract log
///
/// Log，(Console)，(File), (Network)

public protocol JJLogOutput {
    
    /// queue, customer's DispatchQueue
    ///
    /// If queue != nil , will process async queue
    /// If queue == nil , will process current queue
    var queue: DispatchQueue? {
        get
    }
    
    /// Handle log
    /// - Parameter level: level
    /// - Parameter msg: Log message
    /// - Parameter thread: thread
    /// - Parameter file: file name
    /// - Parameter function: funcation name
    /// - Parameter line: source line
    func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int)
    
    /// Log level
    var logLevel: JJSwiftLog.Level {
        get
        set
    }
    
    /// Object identifier, override the equals, defalut value is current object name
    var identifier: String {
        get
    }
    
    /// JJLogOutput object callback
    var delegate: JJLogOutputDelegate? {
        get
        set
    }
    
    /// Execute all formatters，formatted result one by one
    var formatters: [JJLogFormatterProtocol]? {
        get
        set
    }
    
    /// Execute all filters，if a filter return true, this log will end
    var filters: [JJLogFilter]? {
        get
        set
    }
    
    /// Format log
    @available(*, deprecated, message: "Use formatters property instead")
    var formatter: JJLogFormatterProtocol? {
        get
        set
    }
    
    /// Filt log
    @available(*, deprecated, message: "Use filters property instead")
    var filter: JJLogFilter? {
        get
        set
    }
    
}

public extension JJLogOutput {
    
    /// Identifier value is object name
    var identifier: String {
        return String(describing: type(of: self))
    }
    
}

/// Check JJLogOutput implment object only one
/// - Parameter lhs: JJLogOutput
/// - Parameter rhs: JJLogOutput
func == (lhs: JJLogOutput, rhs: JJLogOutput) -> Bool {
    return lhs.identifier == rhs.identifier
}

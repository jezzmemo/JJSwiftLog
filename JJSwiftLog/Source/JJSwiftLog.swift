//
//  JJSwiftLog.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// JJSwiftLog short name
public let jjLogger = JJSwiftLog.self

/// New JJSwiftLog short name
public let JJLogger = JJSwiftLog.self

/// JJSwiftLog main
///
/// JJSwiftLog(Console,File,Network)，Support customer process the log

public struct JJSwiftLog {
    
    /// Log level
    public enum Level: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }
    
    // MARK: - Property
    
    private static var outputs = [JJLogOutput]()
    
    private static let semaphore = DispatchSemaphore(value: 1)
    
    private static var onlyShowLogFileName: String?
    
    // MARK: - Public
    
    /// Default enable log
    public static var enable = true
    
    /// Customer log format, default is nil
    public static var format: String? {
        didSet {
            if self.format != nil {
                JJLogFormatter.shared.formatLog(format!)
            }
        }
    }
    
    /// Simple log format
    public static let simpleFormat = "%D -> %F:%l - %f %M"
    
    /// Add customer process log
    /// - Parameter output: JJLogOutput
    public static func addLogOutput(_ output: JJLogOutput) {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        let index = outputs.firstIndex(where: { (out) -> Bool in
            return out == output
        })
        if index == nil {
            outputs.append(output)
        }
    }
    
    /// Remove customer JJLogOutput
    /// - Parameter output: JJLogOutput
    public static func removeLogOutput(_ output: JJLogOutput) {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        let index = outputs.firstIndex(where: { (out) -> Bool in
            return out == output
        })
        if index != nil {
            outputs.remove(at: index!)
        }
    }
    
    /// Process only show log file
    /// - Parameter filename: File name without suffix
    public static func onlyLogFile(_ filename: String) {
        onlyShowLogFileName = filename
    }
    
    // MARK: - Log Level
    
    /// Verbose
    /// - Parameter message: message
    public static func verbose(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .verbose, message: message(), file: file, function: function, line: line)
    }
    
    /// Debug
    /// - Parameter message: message
    public static func debug(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .debug, message: message(), file: file, function: function, line: line)
    }
    
    /// Info
    /// - Parameter message: message
    public static func info(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .info, message: message(), file: file, function: function, line: line)
    }
    
    /// Warn
     /// - Parameter message: message
    public static func warning(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .warning, message: message(), file: file, function: function, line: line)
    }
    
    /// Error
     /// - Parameter message: message
    public static func error(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .error, message: message(), file: file, function: function, line: line)
    }
    
    /// Customer log
    /// - Parameter level: level
    /// - Parameter message: message
    /// - Parameter file: file
    /// - Parameter function: function
    /// - Parameter line: line
    public static func custom(level: JJSwiftLog.Level, message: String,
                              file: String = #file, function: String = #function, line: Int = #line) {

        /// Filter onlyShowLogFileName
        if let fileName = onlyShowLogFileName, JJLogOutputConfig.fileNameWithoutSuffix(file) != fileName {
            return
        }
        
        if !enable {
            return
        }
        
        let threadName = self.threadName()
        
        for output in outputs {
            guard let outputQueue = output.queue else {
                continue
            }
            if output.logLevel.rawValue > level.rawValue {
                continue
            }
            
            outputQueue.async {
                output.log(level, msg: message, thread: threadName, file: file, function: function, line: line)
            }
        }
    }
}

extension JJSwiftLog {
    
    static func threadName() -> String {
        if Thread.isMainThread {
            return ""
        } else {
            let threadName = Thread.current.name
            if let threadName = threadName, !threadName.isEmpty {
                return threadName
            } else {
                return String(format: "%p", Thread.current)
            }
        }
    }
    
}

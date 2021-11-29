//
//  JJConsoleOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import CRT
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported runtime")
#endif

/// Console log
///
/// Implement UNIX's `stdout`
public struct JJConsoleOutput: JJLogOutput {
    
    /// File pointer
    private let _stdoutFilePointer: UnsafeMutablePointer<FILE>?
    private let _stderrFilePointer: UnsafeMutablePointer<FILE>?
    
    /// Console queue
    private var _consoleQueue: DispatchQueue?
    
    /// Default log level verbose
    private var _consoleLevel: JJSwiftLog.Level = .verbose
    
    /// Use NSLog show console message
    ///
    /// Default value is false
    public var isUseNSLog: Bool = false
    
    public var queue: DispatchQueue? {
        return _consoleQueue
    }
    
    public var logLevel: JJSwiftLog.Level {
        get {
            return _consoleLevel
        }
        set {
            _consoleLevel = newValue
        }
    }
    
    public init() {
        _consoleQueue = DispatchQueue(label: "JJConsoleOutput", target: _consoleQueue)
        #if os(macOS) || os(tvOS) || os(iOS) || os(watchOS)
        _stdoutFilePointer = Darwin.stdout
        _stderrFilePointer = Darwin.stderr
        #elseif os(Windows)
        _stdoutFilePointer = CRT.stdout
        _stderrFilePointer = CRT.stderr
        #elseif canImport(Glibc)
        _stdoutFilePointer = Glibc.stdout
        _stderrFilePointer = Glibc.stderr
        #else
        #error("Unsupported runtime")
        #endif
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) {
        let message = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        if isUseNSLog {
            NSLog("%@", message)
        } else {
            self.writeMessageToConsole(message, isError: level == .error ? true : false)
        }
    }
    
    /// Write message to the std I/O
    /// - Parameters:
    ///   - message: string log
    ///   - isError: is error level
    private func writeMessageToConsole(_ message: String, isError: Bool) {
        if isError && self._stderrFilePointer != nil {
            self.writeStringToFile(message, filePointer: self._stderrFilePointer!)
            return
        }
        if self._stdoutFilePointer != nil {
            self.writeStringToFile(message, filePointer: self._stdoutFilePointer!)
        }
    }
    
}

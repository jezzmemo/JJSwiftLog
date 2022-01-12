//
//  JJConsoleOutput.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
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
open class JJConsoleOutput: JJLogObject {
    
    /// File pointer
    private var _stdoutFilePointer: UnsafeMutablePointer<FILE>?
    private var _stderrFilePointer: UnsafeMutablePointer<FILE>?
    
    /// Use NSLog show console message
    ///
    /// Default value is false
    public var isUseNSLog: Bool = false
    
    public init(identifier: String = "") {
        super.init(identifier: identifier, delegate: nil)
        self.queue = DispatchQueue(label: "JJConsoleOutput")
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
    
    open override func output(log: JJLogEntity, message: String) {
        if isUseNSLog {
            NSLog("%@", message)
        } else {
            self.writeMessageToConsole(message, isError: log.level == .error ? true : false)
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

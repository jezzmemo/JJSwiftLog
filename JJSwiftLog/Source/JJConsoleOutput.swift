//
//  JJConsoleOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation
import Darwin

/// 控制台输出
///
/// 这里控制输出并没有使用print,NSLog，而是使用UNIX的stdout
public struct JJConsoleOutput: JJLogOutput {
    
    /// 操作文件的指针
    private let _filePointer: UnsafeMutablePointer<FILE>?
    
    /// Console自定义队列
    private var _consoleQueue: DispatchQueue? = nil
    
    /// Console默认日志级别是verbose
    private var _consoleLevel: JJSwiftLog.Level = .verbose
    
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
        _consoleQueue = DispatchQueue(label: "JJConsoleOutput",target: _consoleQueue)
        _filePointer = Darwin.stdout
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) -> String? {
        let message = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        self.writeMessageToConsole(message)
        return message
    }
    
    private func writeMessageToConsole(_ message: String) {
        if self._filePointer != nil {
            self.writeStringToFile(message, filePointer: self._filePointer!)
        }
    }
    
    
}

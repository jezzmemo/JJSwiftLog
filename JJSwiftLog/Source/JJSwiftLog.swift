//
//  JJSwiftLog.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// JJSwiftLog的别名，方便开发者快速使用
public let jjLogger = JJSwiftLog.self

/// JJSwiftLog日志入口
///
/// JJSwiftLog内置三个输出(Console,File,Network)，用户也可以自定义

public struct JJSwiftLog {
    
    /// 日志级别
    public enum Level: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }
    
    // MARK: - JJLogOutput
    
    private static var outputs = [JJLogOutput]()
    
    private static let semaphore = DispatchSemaphore(value: 1)
    
    private static var onlyShowLogFileName: String? = nil
    
    // MARK: - Public
    
    /// 是否启用，默认是打开的
    public static var enable = true
    
    /// 格式化日志
    public static var format: String? {
        didSet {
            if self.format != nil {
                JJLogFormatter.shared.formatLog(format!)
            }
        }
    }
    
    /// 内置简单的自定义日志样式
    public static let simpleFormat = "%D -> %F:%l - %f %M"
    
    /// 日志输出集合，用于多个输出，由各自的业务特点控制输出
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
    
    /// 删除自定义输出
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
    
    /// 当前只显示指定文件的日志，默认是显示全部文件的日志
    /// - Parameter filename: 文件名称
    public static func onlyLogFile(_ filename: String) {
        onlyShowLogFileName = filename
    }
    
    //MARK: - Log Level
    
    /// Verbose级别日志，在只有在调式阶段使用，发布后此级别不生效
    /// - Parameter message: 日志
    public static func verbose(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .verbose, message: message(),file: file,function: function,line: line)
    }
    
    /// Debug级别日志，只有在Debug才会使用，发布后不生效，但是如果打开Debug又可使用
    /// - Parameter message: 日志信息
    public static func debug(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .debug, message: message(),file: file,function: function,line: line)
    }
    
    /// Info级别日志，这些级别日志很重要，重要步骤需要，可以辅助排查线上问题
    /// - Parameter message: 日志信息
    public static func info(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .info, message: message(),file: file,function: function,line: line)
    }
    
    /// Warn级别日志，显示一些业务错误，逻辑错误
     /// - Parameter message: 日志信息
    public static func warning(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .warning, message: message(),file: file,function: function,line: line)
    }
    
    /// Error级别日志，代码运行错误
     /// - Parameter message: 日志信息
    public static func error(_ message: @autoclosure() -> String, file: String = #file, function: String = #function, line: Int = #line) {
        custom(level: .error, message: message(),file: file,function: function,line: line)
    }
    
    /// 指定级别日志
    /// - Parameter level: 日志级别
    /// - Parameter message: 日志内容
    /// - Parameter file: 日志所在文件
    /// - Parameter function: 日志所在函数
    /// - Parameter line: 日志所在行数
    public static func custom(level: JJSwiftLog.Level, message: String,
                              file: String = #file, function: String = #function, line: Int = #line) {
        
        
        /// 如果onlyShowLogFileName配置过且不等于当前文件名，将忽略本次日志
        if let fileName = onlyShowLogFileName,  JJLogOutputConfig.fileNameWithoutSuffix(file) != fileName {
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

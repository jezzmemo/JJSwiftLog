//
//  JJLogOutput+Extension.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation


extension JJSwiftLog.Level {
    
    public var stringLevel: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARN"
        case .error:
            return "ERROR"
        }
    }
    
    public var emojiLevel: String {
        switch self {
        case .verbose:
            return "📗"
        case .debug:
            return "📘"
        case .info:
            return "📓"
        case .warning:
            return "📙"
        case .error:
            return "📕"
        }
    }
    
}

extension JJLogOutput {
    
    /// 根据日志级别，线程，文件，函数，行数组成的字符串
    /// - Parameter level: 日志级别
    /// - Parameter msg: 开发输入的信息
    /// - Parameter thread: 当前线程
    /// - Parameter file: 文件名
    /// - Parameter function: 函数名
    /// - Parameter line: 日志当前行
    func formatMessage(level: JJSwiftLog.Level, msg: String, thread: String,
                       file: String, function: String, line: Int) -> String {
        if JJLogFormatter.shared.segments.count > 0 {
            return formatSegmentMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        }
        var text = ""
        text += self.formatDate(JJLogOutputConfig.formatter) + JJLogOutputConfig.padding
        text += level.emojiLevel + JJLogOutputConfig.padding
        text += thread.isEmpty ? "" : (thread + JJLogOutputConfig.padding)
        text += JJLogOutputConfig.fileNameWithoutSuffix(file)  + JJLogOutputConfig.point
        text += function + JJLogOutputConfig.padding
        text += "\(line)" + JJLogOutputConfig.padding
        text += level.stringLevel + JJLogOutputConfig.padding
        text += msg
        text += JJLogOutputConfig.newline
        return text
    }
    
    /// 自定义格式的日志
    /// - Parameters:
    ///   - level: 日志级别
    ///   - msg: 信息
    ///   - thread: 线程
    ///   - file: 文件名
    ///   - function: 函数
    ///   - line: 行数
    func formatSegmentMessage(level: JJSwiftLog.Level, msg: String, thread: String,
                              file: String, function: String, line: Int) -> String {
        var text = ""
        let segments = JJLogFormatter.shared.segments
        for segment in segments {
            switch segment {
            case .token(let option, let string):
                switch option {
                case .message:
                    text += (msg + string)
                    break
                case .level:
                    text += (level.stringLevel + string)
                    break
                case .line:
                    text += ("\(line)" + string)
                    break
                case .file:
                    text += (JJLogOutputConfig.fileNameWithoutSuffix(file) + string)
                    break
                case .function:
                    text += (function + string)
                    break
                case .date:
                    text += (self.formatDate(JJLogOutputConfig.formatter) + string)
                    break
                case .thread:
                    text += thread.isEmpty ? "" : thread
                    break
                case .origin:
                    text += string
                    break
                case .ignore:
                    text += string
                    break
                }
            }
        }
        text += JJLogOutputConfig.newline
        return text
    }
    
    /// 格式化日期
    /// - Parameter dateFormat: 日期格式
    /// - Parameter timeZone: 时区
    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
        
        if !timeZone.isEmpty {
            JJLogOutputConfig.formatDate.timeZone = TimeZone(abbreviation: timeZone)
        }
        JJLogOutputConfig.formatDate.dateFormat = dateFormat
        let dateStr = JJLogOutputConfig.formatDate.string(from: Date())
        return dateStr
    }
    
    /// 安全写入字符串到FILE
    /// - Parameter string: string
    /// - Parameter filePointer: UnsafeMutablePointer<FILE>
    func writeStringToFile(_ string: String, filePointer: UnsafeMutablePointer<FILE>) {
        string.withCString { ptr in
            
            #if os(Windows)
             _lock_file(filePointer)
             #else
             flockfile(filePointer)
             #endif
            defer {
                #if os(Windows)
                _unlock_file(filePointer)
                #else
                funlockfile(filePointer)
                #endif
            }
            
            _ = fputs(ptr, filePointer)
            _ = fflush(filePointer)
        }
    }
    
}

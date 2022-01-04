//
//  JJLogOutput+Extension.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// Extension for JJSwiftLog.Level
extension JJSwiftLog.Level {

    /// String level
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

    /// Emoji level
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
    
    /// Generate log from log level,thread,file name,function line number
    /// - Parameter level: log level
    /// - Parameter msg: text
    /// - Parameter thread: thread
    /// - Parameter file: file name
    /// - Parameter function: function
    /// - Parameter line: line number
    func formatMessage(level: JJSwiftLog.Level, msg: String, thread: String,
                       file: String, function: String, line: Int) -> String {
        if !JJLogFormatter.shared.segments.isEmpty {
            return formatSegmentMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        }
        var text = ""
        text += self.formatDate(JJLogOutputConfig.dateTimezoneformatter) + JJLogOutputConfig.padding
        text += level.emojiLevel + JJLogOutputConfig.padding
        text += thread.isEmpty ? "" : (thread + JJLogOutputConfig.padding)
        if !file.isEmpty {
            text += JJLogOutputConfig.fileNameWithoutSuffix(file)  + JJLogOutputConfig.point
        }
        if !function.isEmpty {
            text += function + JJLogOutputConfig.padding
        }
        if line != 0 {
            text += "\(line)" + JJLogOutputConfig.padding
        }
        text += level.stringLevel + JJLogOutputConfig.padding
        text += msg
        text += JJLogOutputConfig.newline
        return text
    }

    /// Format segment message
    /// - Parameters:
    ///   - level: Log level
    ///   - msg: Text message
    ///   - thread: Thread name
    ///   - file: File name, suffix extension
    ///   - function: Function
    ///   - line: Function line number
    /// - Returns: All info string
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
                case .level:
                    text += (level.stringLevel + string)
                case .line:
                    text += ("\(line)" + string)
                case .file:
                    text += (JJLogOutputConfig.fileNameWithoutSuffix(file) + string)
                case .fileExtension:
                    text += (JJLogOutputConfig.fileNameOfFile(file) + string)
                case .function:
                    text += (function + string)
                case .date:
                    text += (self.formatDate(JJLogOutputConfig.dateTimezoneformatter) + string)
                case .onlyDate:
                    text += (self.formatDate(JJLogOutputConfig.dateFormatter) + string)
                case .time:
                    text += (self.formatDate(JJLogOutputConfig.timeFormatter) + string)
                case .thread:
                    text += thread.isEmpty ? "" : thread
                case .origin:
                    text += string
                case .ignore:
                    text += string
                }
            }
        }
        text += JJLogOutputConfig.newline
        return text
    }
    
    /// Format date
    /// - Parameter dateFormat: Date format
    /// - Parameter timeZone: timeZone
    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
        
        if !timeZone.isEmpty {
            JJLogOutputConfig.formatDate.timeZone = TimeZone(abbreviation: timeZone)
        }
        JJLogOutputConfig.formatDate.dateFormat = dateFormat
        let dateStr = JJLogOutputConfig.formatDate.string(from: Date())
        return dateStr
    }
    
    /// Write string to filepointer
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

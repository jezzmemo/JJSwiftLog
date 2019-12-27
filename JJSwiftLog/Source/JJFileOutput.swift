//
//  JJFileOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// 日志文件输出
public struct JJFileOutput: JJLogOutput {
    
    /// 操作文件的指针
    private let _filePointer: UnsafeMutablePointer<FILE>?
    
    /// 文件的绝对地址
    private(set) var logFilePath: String?
    
    /// 默认文件日志级别verbose
    private var _logLevel: JJSwiftLog.Level = .verbose
    
    /// 文件日志的队列
    private var _logQueue: DispatchQueue? = nil
    
    public var logLevel: JJSwiftLog.Level {
        get {
            return _logLevel
        }
        set {
            _logLevel = newValue
        }
    }
    
    public var queue: DispatchQueue? {
        return _logQueue
    }
    
    /// 初始化文件路径，是可选类型，如果nil，默认将给用户存储在cachesDirectory
    ///
    /// - Parameter filePath: 文件路径
    public init?(filePath: String? = nil) {
        
        if let filePath = filePath {
            logFilePath = filePath
        } else {
            guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return nil
            }
            
            let logFileURL = url.appendingPathComponent("jjlogger.log", isDirectory: false)
            logFilePath = logFileURL.relativePath
        }
        
        _filePointer = fopen(logFilePath!, "aw+")
        
        if _filePointer == nil {
            print("Create file pointer failed")
            return nil
        }
        
        if #available(iOS 10.0, *) {
            do {
                var attributes = try FileManager.default.attributesOfItem(atPath: logFilePath ?? "")
                attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                try FileManager.default.setAttributes(attributes, ofItemAtPath: logFilePath ?? "")
            } catch _ {
                print("Set file protectionKey failed")
            }
        }
        
        _logQueue = DispatchQueue(label: "JJLogFile" ,target: _logQueue)
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) -> String? {
        let formatMessage = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        self.write(string: formatMessage)
        return formatMessage
    }
    
    /// 写入日志信息到文件
    /// - Parameter string: 日志信息
    private func write(string: String) {
        
        //检查文件是否存在，不存在需要重新创建
        if access(logFilePath, F_OK) == -1 {
            freopen(logFilePath, "w+", _filePointer)
        }
        
        if _filePointer != nil {
            self.writeStringToFile(string, filePointer: _filePointer!)
        }
    }
    
}

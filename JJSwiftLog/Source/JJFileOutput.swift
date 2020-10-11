//
//  JJFileOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// Save the log to file
///
/// Implement by the FILE Pointer
public struct JJFileOutput: JJLogOutput {
    
    /// File pointer
    private let _filePointer: UnsafeMutablePointer<FILE>?
    
    /// File path
    private(set) var logFilePath: String?
    
    /// Default file level verbose
    private var _logLevel: JJSwiftLog.Level = .verbose
    
    /// File queue
    private var _logQueue: DispatchQueue?
    
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
    
    /// if filePath nil，the log will save to `cachesDirectory`
    ///
    /// - Parameter filePath: File path
    public init?(filePath: String? = nil) {
        
        if let filePath = filePath {
            logFilePath = filePath
        } else {
            #if os(tvOS) || os(iOS) || os(watchOS)
            guard let appURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return nil
            }
            
            #elseif os(macOS)
            guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return nil
            }
            
            guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String else {
                return nil
            }
            
            let appURL = url.appendingPathComponent(appName, isDirectory: true)
            try? FileManager.default.createDirectory(at: appURL, withIntermediateDirectories: true, attributes: nil)
            
            #elseif os(Linux)
            let appURL = URL(fileURLWithPath: "/var/cache/")
            #else
            //TODO: Windows
            #endif
            let logFileURL = appURL.appendingPathComponent("jjlogger.log", isDirectory: false)
            logFilePath = logFileURL.relativePath
        }
        
        _filePointer = fopen(logFilePath!, "aw+")
        
        if _filePointer == nil {
            print("Create file pointer failed")
            return nil
        }
        #if os(iOS) || os(watchOS) || os(tvOS)
        if #available(iOS 10.0, *) {
            do {
                var attributes = try FileManager.default.attributesOfItem(atPath: logFilePath ?? "")
                attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                try FileManager.default.setAttributes(attributes, ofItemAtPath: logFilePath ?? "")
            } catch _ {
                print("Set file protectionKey failed")
            }
        }
        #endif
        
        _logQueue = DispatchQueue(label: "JJLogFile", target: _logQueue)
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) {
        let formatMessage = self.formatMessage(level: level, msg: msg, thread: thread, file: file, function: function, line: line)
        self.write(string: formatMessage)
    }
    
    /// Write log to file
    /// - Parameter string: Log text
    private func write(string: String) {
        
        //Check file exist, if not exist will recreate
        if access(logFilePath, F_OK) == -1 {
            freopen(logFilePath, "w+", _filePointer)
        }
        
        if _filePointer != nil {
            self.writeStringToFile(string, filePointer: _filePointer!)
        }
    }
    
}

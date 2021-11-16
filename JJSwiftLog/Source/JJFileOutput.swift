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
public class JJFileOutput: JJLogOutput {
    
    public static let maxFileSize: UInt64 = 1_048_576
    
    public static let maxTimeInterval: TimeInterval = 600
    
    /// The base file name of the log file
    private var baseFileName: String = "jjlogger"
    
    /// The extension of the log file name
    private var fileExtension: String = "log"
    
    /// Size of the current log file
    internal var currentLogFileSize: UInt64 = 0

    /// Start time of the current log file
    internal var currentLogStartTimeInterval: TimeInterval = 0
    
    // MARK: - Properties
    public var targetMaxFileSize: UInt64 = maxFileSize {
        didSet {
            if targetMaxFileSize < 1 {
                targetMaxFileSize = .max
            }
        }
    }

    public var targetMaxTimeInterval: TimeInterval = maxTimeInterval {
        didSet {
            if targetMaxTimeInterval < 1 {
                targetMaxTimeInterval = 0
            }
        }
    }

    public var targetMaxLogFiles: UInt8 = 10 {
        didSet {
            clearLogFiles()
        }
    }

    /// Option: the URL of the folder to store archived log files (defaults to the same folder as the initial log file)
    public var archiveFolderURL: URL? = nil {
        didSet {
            guard let archiveFolderURL = archiveFolderURL else { return }
            try? FileManager.default.createDirectory(at: archiveFolderURL, withIntermediateDirectories: true)
        }
    }
    
    lazy var archiveDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "_yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
    
    static var defaultLogFolderURL: URL {
        var defaultLogFolderURL: URL
#if os(tvOS) || os(iOS) || os(watchOS)
        defaultLogFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
#elseif os(macOS)
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String else {
            return nil
        }
        
        defaultLogFolderURL = url.appendingPathComponent(appName, isDirectory: true)
        try? FileManager.default.createDirectory(at: appURL, withIntermediateDirectories: true, attributes: nil)
        
#elseif os(Linux)
        defaultLogFolderURL = URL(fileURLWithPath: "/var/cache/")
#endif
        return defaultLogFolderURL
    }
    
    /// File pointer
    private var _filePointer: UnsafeMutablePointer<FILE>?
    
    /// File path, default path is cachesDirectory
    ///
    /// If device space warning, the cache file will remove by the system
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
            logFilePath = self.logFileURL.relativePath
        }
        
        self.createNewFile(filePath: logFilePath!)
        
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
                currentLogFileSize = attributes[.size] as? UInt64 ?? 0
                currentLogStartTimeInterval = (attributes[.creationDate] as? Date ?? Date()).timeIntervalSince1970
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
        
        currentLogFileSize += UInt64(string.count)
        
        //Check file exist, if not exist will recreate
        if access(logFilePath, F_OK) == -1 {
            freopen(logFilePath, "w+", _filePointer)
        }
        
        //Write string to file
        if _filePointer != nil {
            self.writeStringToFile(string, filePointer: _filePointer!)
        }
        
        //Check need to create new file
        if needNewFile() {
            createNewFile()
        }
    }
    
}

extension JJFileOutput {
    
    var logFileURL: URL {
        var archiveFolderURL: URL = (self.archiveFolderURL ?? JJFileOutput.defaultLogFolderURL)
        archiveFolderURL = archiveFolderURL.appendingPathComponent("\(baseFileName)\(archiveDateFormatter.string(from: Date()))")
        archiveFolderURL = archiveFolderURL.appendingPathExtension(fileExtension)
        return archiveFolderURL
    }
    
    public func createNewFile(filePath: String) {
        if _filePointer != nil {
            fflush(_filePointer)
            fclose(_filePointer)
            _filePointer = nil
        }
        _filePointer = fopen(filePath, "aw+")
    }
    
    public func createNewFile() {
      
        let archiveFolderURL = self.logFileURL
        
        self.createNewFile(filePath: archiveFolderURL.relativePath)

        currentLogStartTimeInterval = Date().timeIntervalSince1970
        currentLogFileSize = 0

        clearLogFiles()
    }
    
    func clearLogFiles() {
        var archivedFileURLs: [URL] = self.archivedURLs()
        guard archivedFileURLs.count > Int(targetMaxLogFiles) else { return }
        
        archivedFileURLs.removeFirst(Int(targetMaxLogFiles))
        
        let fileManager: FileManager = FileManager.default
        for archivedFileURL in archivedFileURLs {
            do {
                try fileManager.removeItem(atPath: archivedFileURL.path)
            } catch let error as NSError {
                JJLogger.error("CleanUpLogFiles log file error:\(error.localizedDescription)")
            }
        }
    }
    
    func archivedURLs() -> [URL] {
        let archiveFolderURL: URL = (self.archiveFolderURL ?? type(of: self).defaultLogFolderURL)
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: archiveFolderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return [] }
        
        
        var archivedDetails: [(url: URL, timestamp: TimeInterval)] = []
        for fileURL in fileURLs {
            let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
            let date = attributes?[.creationDate] as? Date ?? Date()
            archivedDetails.append((fileURL, date.timeIntervalSince1970))
        }
        
        archivedDetails.sort(by: { (lhs, rhs) -> Bool in lhs.timestamp > rhs.timestamp })
        var archivedFileURLs: [URL] = []
        for archivedDetail in archivedDetails {
            archivedFileURLs.append(archivedDetail.url)
        }
        
        return archivedFileURLs
    }
    
    
    public func needNewFile() -> Bool {
        
        guard currentLogFileSize < targetMaxFileSize else { return true }
        
        guard targetMaxTimeInterval > 0 else { return false }
        
        guard Date().timeIntervalSince1970 - currentLogStartTimeInterval < targetMaxTimeInterval else { return true }
        return false
    }
}

extension JJFileOutput {


    /// Delete log file
    /// - Returns: true delete success, false delete failed
    public func deleteLogFile() -> Bool {
        guard let filePath = self.logFilePath else {
            return false
        }
        guard FileManager.default.fileExists(atPath: filePath)  else {
            return false
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch let error {
            JJLogger.warning("Delete log file error:\(error.localizedDescription)")
            return false
        }
    }

    /// Archive log file to customer path
    /// - Parameter logFilePath: Customer path
    public func archiveLogFilePath(_ logFilePath: String) {
        guard let filePath = self.logFilePath else {
            return
        }
        guard FileManager.default.fileExists(atPath: filePath)  else {
            return
        }
        do {
            if FileManager.default.fileExists(atPath: logFilePath) {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: logFilePath))
            }
            try FileManager.default.copyItem(atPath: filePath, toPath: logFilePath)
        } catch let error {
            JJLogger.warning("Copy log file error:\(error.localizedDescription)")
        }
    }
}

//
//  JJFileOutput.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// Save the log to file
///
/// Implement by the FILE Pointer
open class JJFileOutput: JJLogObject {
    
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
    public var archiveFolderURL: URL? {
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
        defaultLogFolderURL = defaultLogFolderURL.appendingPathComponent("jjlogger")
        try? FileManager.default.createDirectory(at: defaultLogFolderURL, withIntermediateDirectories: true)
#elseif os(macOS)
        defaultLogFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("jjlogger")
        try? FileManager.default.createDirectory(at: defaultLogFolderURL, withIntermediateDirectories: true, attributes: nil)
        
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
    
    /// if filePath nil，the log will save to `cachesDirectory`
    ///
    /// - Parameter filePath: File path
    /// - Parameter delegate: Current object callback
    /// - Parameter identifier: Output object identifier
    public init?(filePath: String? = nil, delegate: JJLogOutputDelegate? = nil, identifier: String = "") {
        super.init(identifier: identifier, delegate: delegate)
        
        if let filePath = filePath {
            logFilePath = filePath
        } else {
            logFilePath = self.logFileURL.relativePath
        }
        
        self.createNewFilePointer(filePath: logFilePath!)
        
        if _filePointer == nil {
            self.makeCallbackLog(message: "Create file pointer failed")
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
            } catch let error {
                self.makeCallbackLog(message: error.localizedDescription)
            }
        }
        #endif
        self.queue = DispatchQueue(label: "JJFileOutput")
        self.makeCallbackLog(message: ">>> JJSwiftLog Writing path: " + logFilePath!)
    }
    
    open override func output(log: JJLogEntity, message: String) {
        self.write(string: message)
    }
    
    /// Write log to file
    /// - Parameter string: Log text
    private func write(string: String) {
        
        currentLogFileSize += UInt64(string.count)
        
        // Check file exist, if not exist will recreate
        if access(logFilePath, F_OK) == -1 {
            freopen(logFilePath, "w+", _filePointer)
        }
        
        // Write string to file
        if _filePointer != nil {
            self.writeStringToFile(string, filePointer: _filePointer!)
        }
        
        // Check need to create new file
        if needNewFile() {
            createNewFile()
        }
    }
}

extension JJFileOutput {
    
    /// Log file url
    var logFileURL: URL {
        var archiveFolderURL: URL = (self.archiveFolderURL ?? JJFileOutput.defaultLogFolderURL)
        archiveFolderURL = archiveFolderURL.appendingPathComponent("\(baseFileName)\(archiveDateFormatter.string(from: Date()))")
        archiveFolderURL = archiveFolderURL.appendingPathExtension(fileExtension)
        return archiveFolderURL
    }
    
    /// Create new file pointer
    /// - Parameter filePath: filePath
    public func createNewFilePointer(filePath: String) {
        if _filePointer != nil {
            fclose(_filePointer)
            _filePointer = nil
        }
        _filePointer = fopen(filePath, "aw+")
    }
    
    /// Create new file
    public func createNewFile() {
      
        let archiveFolderURL = self.logFileURL
        
        self.createNewFilePointer(filePath: archiveFolderURL.relativePath)

        currentLogStartTimeInterval = Date().timeIntervalSince1970
        currentLogFileSize = 0

        clearLogFiles()
    }
    
    /// Clear the greater the targetMaxLogFiles size
    func clearLogFiles() {
        var archivedFileURLs: [URL] = self.archivedURLs()
        guard archivedFileURLs.count > Int(targetMaxLogFiles) else { return }
        
        archivedFileURLs.removeFirst(Int(targetMaxLogFiles))
        
        let fileManager: FileManager = FileManager.default
        for archivedFileURL in archivedFileURLs {
            do {
                try fileManager.removeItem(at: archivedFileURL)
            } catch let error as NSError {
                self.makeCallbackLog(message: error.localizedDescription)
            }
        }
    }
    
    /// Archived the log files URL
    /// - Returns: [URL]
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
     
    /// Check the need to new file status
    /// - Returns: Ture or False
    public func needNewFile() -> Bool {
        
        guard currentLogFileSize < targetMaxFileSize else { return true }
        
        guard targetMaxTimeInterval > 0 else { return false }
        
        guard Date().timeIntervalSince1970 - currentLogStartTimeInterval < targetMaxTimeInterval else { return true }
        return false
    }
}

extension JJFileOutput {
    
    func makeCallbackLog(message: String) {
        let log = JJLogEntity(level: .info, date: Date(), message: message, functionName: "", fileName: "", lineNumber: 0)
        self.delegate?.internalLog(source: self, log: log)
    }

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
            self.makeCallbackLog(message: error.localizedDescription)
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
            self.makeCallbackLog(message: error.localizedDescription)
        }
    }
}

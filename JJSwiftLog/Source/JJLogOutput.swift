//
//  JJLogOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation

/// Constant value
internal struct JJLogOutputConfig {
    
    static let padding = " "
    
    static let dateTimezoneformatter = "yyyy-MM-dd HH:mm:ss.SSSZ"

    static let timeFormatter = "HH:mm:ss"

    static let dateFormatter = "yyyy-MM-dd"
    
    static let formatDate = DateFormatter()
    
    static let newline = "\n"
    
    static let point = "."
    
    /// Get file name from file string
    /// - Parameter file: File path
    static func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }
    
    /// Get file name with out suffix
    /// - Parameter file: File path
    static public func fileNameWithoutSuffix(_ file: String) -> String {
        let fileName = fileNameOfFile(file)

        if !fileName.isEmpty {
            let fileNameParts = fileName.components(separatedBy: ".")
            if let firstPart = fileNameParts.first {
                return firstPart
            }
        }
        return ""
    }
}

/// Abstract log
///
/// Log，(Console)，(File), (Network)

public protocol JJLogOutput {
    
    /// queue
    var queue: DispatchQueue? {
        get
    }
    
    /// Handle log
    /// - Parameter level: level
    /// - Parameter msg: Log message
    /// - Parameter thread: thread
    /// - Parameter file: file name
    /// - Parameter function: funcation name
    /// - Parameter line: source line
    func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int)
    
    /// Log level
    var logLevel: JJSwiftLog.Level {
        get
        set
    }
    
}

/// Check JJLogOutput implment object only one
/// - Parameter lhs: JJLogOutput
/// - Parameter rhs: JJLogOutput
func == (lhs: JJLogOutput, rhs: JJLogOutput) -> Bool {
    guard type(of: lhs) == type(of: rhs) else {
        return false
    }
    return true
}

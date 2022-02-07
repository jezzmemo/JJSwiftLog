//
//  JJLogFormat.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/1/2.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// Log format protocol
public protocol JJLogFormatterProtocol {
    
    /// Format object to String
    /// - Parameters:
    ///   - log: Origin log object
    ///   - message: Previous formatter result
    /// - Returns: Format string result
    func format(log: JJLogEntity, message: String) -> String
    
}

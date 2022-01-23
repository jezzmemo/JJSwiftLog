//
//  JJLogFilter.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/1/9.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// Filter the log message
public protocol JJLogFilter {
    
    /// Filter the log object and format message
    /// - Returns: If return true, will ignore the log, if return false, will handle log
    func ignore(log: JJLogEntity, message: String) -> Bool
}

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
    /// - Returns: Format result
    func format(log: JJLogEntity) -> String
    
}

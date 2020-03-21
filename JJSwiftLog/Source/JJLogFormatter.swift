//
//  JJLogFormatter.swift
//  JJSwiftLog
//
//  Created by Jezz on 2020/2/15.
//  Copyright © 2020 JJSwiftLog. All rights reserved.
//

import Foundation


/// 格式化选项
public enum FormatterOption: String {
    case message = "%message"
    case level = "%level"
    case line = "%line"
    case file = "%file"
    case date = "%date"
}

/// 格式化日志
public struct JJLogFormatter {
    let formatString: String
    
    init(formatString: String) {
        self.formatString = formatString
    }
    
    func formatLog(_ originStringLog: String) -> String? {
        return nil
    }
}

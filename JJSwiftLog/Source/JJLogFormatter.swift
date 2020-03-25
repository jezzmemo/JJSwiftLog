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
    case message = "M"
    case level = "L"
    case line = "l"
    case file = "F"
    case function = "f"
    case date = "D"
    case thread = "T"
    case origin = "origin"
}

/// 格式化结果
public enum LogSegment {
    
    case token(FormatterOption, String)
    
}

/// 处理格式化配置，生产内部定义
public class JJLogFormatter {
    
    public static let shared: JJLogFormatter = {
        let format = JJLogFormatter()
        return format
    }()
    
    private init() {
        
    }
    
    lazy public var segments = {
        return [LogSegment]()
    }()
    
    /// 格式化字符串生成日志片段
    /// - Parameter formatter: 格式化字符
    func formatLog(_ formatter: String) {
        let phrases = formatter.components(separatedBy: "%")
        
        for phrase in phrases {
            let (_, offset) = self.parsePadding(phrase)
            
            let formatCharIndex = phrase.index(phrase.startIndex, offsetBy: offset)
            let formatChar = phrase[formatCharIndex]
            
            let rangeAfterFormatChar = phrase.index(formatCharIndex, offsetBy: 1)..<phrase.endIndex
            let remainingPhrase = phrase[rangeAfterFormatChar]
            
            let formatSegment = FormatterOption(rawValue:String(formatChar))
            
            switch formatSegment {
            case .message:
                fallthrough
            case .line:
                fallthrough
            case .file:
                fallthrough
            case .level:
                segments.append(.token(formatSegment!, String(remainingPhrase)))
                break
            default:
                segments.append(.token(.origin, phrase))
                break
            }
            
        }
    }
    
    /// 解析字符串和偏移量
    /// - Parameter text: 字符串
    func parsePadding(_ text: String) -> (Int, Int) {
        let sign: Int = 1
        
        let numString = text.prefix { $0 >= "0" && $0 <= "9" }
        if let num = Int(String(numString)) {
            return (sign * num, (sign == -1 ? 1 : 0) + numString.count)
        } else {
            return (0, 0)
        }
    }
}

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
    // 信息
    case message = "M"
    // 日志级别
    case level = "L"
    // 日志行数
    case line = "l"
    // 日志文件
    case file = "F"
    // 函数名
    case function = "f"
    // 日期
    case date = "D"
    // 线程
    case thread = "T"
    // 原始字符串
    case origin = "origin"
    // 忽略
    case ignore = "I"
}

/// 格式化结果
public enum LogSegment {
    /// 第一参数是日志类型，第二个参数代表有可能是原始字符串，有可能是尾部字符
    case token(FormatterOption, String)
    
}

/// 处理格式化配置，生产内部定义
public final class JJLogFormatter {
    
    public static let shared: JJLogFormatter = {
        let format = JJLogFormatter()
        return format
    }()
    
    private init() {
        
    }
    
    /// 根据格式化生成日志段，输出日志时，再用日志段格式化
    lazy public var segments = {
        return [LogSegment]()
    }()
    
    /// 格式化字符串生成日志片段
    /// - Parameter formatter: 格式化字符
    func formatLog(_ formatter: String) {
        
        if formatter.count == 0 {
            return
        }
        
        self.segments.removeAll()
        
        let phrases = ("%I" + formatter).components(separatedBy: "%")
        
        for phrase in phrases where !phrase.isEmpty {
            let (_, offset) = self.parsePadding(phrase)
            
            let formatCharIndex = phrase.index(phrase.startIndex, offsetBy: offset)
            let formatChar = phrase[formatCharIndex]
            
            let rangeAfterFormatChar = phrase.index(formatCharIndex, offsetBy: 1)..<phrase.endIndex
            let remainingPhrase = phrase[rangeAfterFormatChar]
            
            let formatSegment = FormatterOption(rawValue:String(formatChar))
            
            switch formatSegment {
            case .message:
                fallthrough
            case .date:
                fallthrough
            case .ignore:
                fallthrough
            case .thread:
                fallthrough
            case .line:
                fallthrough
            case .file:
                fallthrough
            case .function:
                fallthrough
            case .level:
                segments.append(.token(formatSegment!, String(remainingPhrase)))
                break
            case .origin:
                segments.append(.token(.origin, phrase))
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

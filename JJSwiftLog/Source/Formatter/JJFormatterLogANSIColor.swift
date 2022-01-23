//
//  JJFormatterLogANSIColor.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/1/16.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation

/// ANSIColor
open class JJFormatterLogANSIColor: JJLogFormatterProtocol {
    
    /// ANSI code
    public static let colorStart = "\u{001b}["

    /// ANSI code
    public static let colorEnd = "\(colorStart)m"
    
    /// Level color dictionary
    internal var levelColor: [JJSwiftLog.Level: String] = [:]
    
    /// ANSI colours
    public enum ANSIColor {
        case green
        case yellow
        case blue
        case magenta
        case cyan
        case black
        case red
        
        public var foregroundColor: String {
            switch self {
            case .green:
                return "32"
            case .yellow:
                return "33"
            case .blue:
                return "34"
            case .magenta:
                return "35"
            case .cyan:
                return "36"
            case .black:
                return "30"
            case .red:
                return "31"
            }
        }
        
        public var backgroundColor: String {
            switch self {
            case .green:
                return "32"
            case .yellow:
                return "33"
            case .blue:
                return "34"
            case .magenta:
                return "35"
            case .cyan:
                return "36"
            case .black:
                return "40"
            case .red:
                return "41"
            }
        }
    }
    
    public init() {
        setupFormatting()
    }
    
    open func setupFormatting() {
        colour(level: .verbose, foregroundColor: .cyan)
        colour(level: .debug, foregroundColor: .green)
        colour(level: .info, foregroundColor: .blue)
        colour(level: .warning, foregroundColor: .yellow)
        colour(level: .error, foregroundColor: .red)
    }
    
    open func colour(level: JJSwiftLog.Level, foregroundColor: ANSIColor = .blue, backgroundColor: ANSIColor = .black) {
        let codes: [String] = [foregroundColor.foregroundColor, backgroundColor.backgroundColor]

        levelColor[level] = JJFormatterLogANSIColor.colorStart + codes.joined(separator: ";") + "m"
    }
    
    public func format(log: JJLogEntity, message: String) -> String {
        let start = levelColor[log.level] ?? ""
        return "\(start)\(message)\(JJFormatterLogANSIColor.colorEnd)"
    }
    
}

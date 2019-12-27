//
//  JJLogOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJSwiftLog. All rights reserved.
//

import Foundation


/// 日志格式化的配置
internal struct JJLogOutputConfig {
    
    static let padding = " "
    
    static let formatter = "yyyy-MM-dd HH:mm:ss.SSS"
    
    static let formatDate = DateFormatter()
    
    static let newline = "\n"
    
    static let point = "."
}

/// 抽象日志的协议
///
/// 将日志抽象为输出，目前支持控制台输出(Console)，文件输出(File)，网络输出(Network)

public protocol JJLogOutput {
    
    /// 输出的私有队列
    var queue: DispatchQueue? {
        get
    }
    
    /// 发送日志
    /// - Parameter level: 日志级别
    /// - Parameter msg: 日志内容
    /// - Parameter thread: 日志线程
    /// - Parameter file: 日志所在文件
    /// - Parameter function: 日志所在函数
    /// - Parameter line: 日志所在行数
    func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) -> String?
    
    /// 日志级别，可读写
    var logLevel: JJSwiftLog.Level {
        get
        set
    }
    
}

/// 同一个JJLogOutput实例只能放入一个到容器里
/// - Parameter lhs: JJLogOutput
/// - Parameter rhs: JJLogOutput
func == (lhs: JJLogOutput, rhs: JJLogOutput) -> Bool{
    guard type(of: lhs) == type(of: rhs) else {
        return false
    }
    return true
}

//
//  UmengOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2020/2/4.
//  Copyright © 2020 JJSwiftLog. All rights reserved.
//

import Foundation

/// 扩展友盟，将日志输出到友盟后台的自定义事件
///
/// 使用`MobClick.event`到友盟的自定义事件菜单里
/// `JJSwiftLog`作为key,并将日志信息拼装成字典，字典的key和value代表意思:
///
/// `msg`:日志内容
///
/// `file`:文件
///
/// `function`:函数
///
/// `line`:行数
public struct UmengOutput: JJLogOutput {
    
    public var queue: DispatchQueue? {
        return DispatchQueue.main
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) -> String? {
        MobClick.event("JJSwiftLog", attributes: ["msg": msg ,"file" :file ,"function" :function ,"line" :line])
        return nil
    }
    
    private var _umengLevel: JJSwiftLog.Level = .verbose
    
    public var logLevel: JJSwiftLog.Level {
        get {
            return _umengLevel
        }
        set {
            _umengLevel = newValue
        }
    }
    
    
}

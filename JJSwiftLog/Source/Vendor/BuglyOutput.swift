//
//  BuglyOutput.swift
//  JJSwiftLog
//
//  Created by Jezz on 2020/2/4.
//  Copyright © 2020 JJSwiftLog. All rights reserved.
//

import Foundation
import Bugly

/// 扩展Bugly，将日志输出到Bugly后台
///
/// 使用Bugly.reportError到Bugly的错误分析菜单，就可以看到所有的信息，还有当前的堆栈信息
/// `JJSwiftLog`作为key,并将日志信息拼装成字典，字典的key和value代表意思:
///
/// `msg`:日志内容
///
/// `file`:文件
///
/// `function`:函数
///
/// `line`:行数
public struct BuglyOutput: JJLogOutput {
    
    public var queue: DispatchQueue? {
        return DispatchQueue.main
    }
    
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String, file: String, function: String, line: Int) -> String? {
        let error = NSError(domain: "JJSwiftLog", code: level.rawValue, userInfo: ["msg": msg ,"file" :file ,"function" :function ,"line" :line])
        Bugly.reportError(error)
        return nil
    }
    
    private var _buglyLevel: JJSwiftLog.Level = .verbose
    
    public var logLevel: JJSwiftLog.Level {
        get {
            return _buglyLevel
        }
        set {
            _buglyLevel = newValue
        }
    }
    
    
}

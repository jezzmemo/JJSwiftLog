[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JJSwiftLog.svg?style=flat)](http://cocoadocs.org/docsets/JJSwiftLog)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJSwiftLog

![JJSwiftLog screenshot](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/main.jpg)

使用Unix file descriptor的stdout原理，将日志模块的日志输出到stdout,然后将日志抽象成接口，内置控制台和文件日志，由开发者自行添加，自定义日志可以满足自行分发到任意渠道.

## 主要功能

- [x] 控制台展示(Console Log)

- [x] 日志文件存储(File Log)

- [x] 用户自定义日志,实现`JJLogOutput`协议即可

- [x] 全局开关日志

- [x] 只显示指定文件日志

- [x] 自定义日志格式

## 如何安装

*  Swift 4.0+


__Podfile__


```
pod 'JJSwiftLog'
```

__Carthage__

```
github "jezzmemo/JJSwiftLog"
```

__Swift Package Manager__

```
.package(url: "https://github.com/jezzmemo/JJSwiftLog.git"),
```

## 如何使用

* 导入模块

```
import JJSwiftLog
```

* 使用示例，__setup必须的__

```swift
func setupLog() {
     if let file = JJFileOutput() {
         jjLogger.addLogOutput(file)
     }
     #if DEBUG
     jjLogger.addLogOutput(JJConsoleOutput())
     #endif
}

override func viewDidLoad() {
     super.viewDidLoad()
     setupLog()
     jjLogger.verbose("verbose")
     jjLogger.debug("debug")   
     jjLogger.info("info")
     jjLogger.warning("warn")
     jjLogger.error("error")
}
```

* 使用`enable`，实时开关日志，默认是开启的

```swift
jjLogger.enable = true
```

* 使用`onlyLogFile`方法，让指定文件显示日志

```swift
jjLogger.onlyLogFile("ViewController")
```

* JJSwiftLog支持自定义格式日志，以下表格是简写字母对应关系:

| 简写   | 描述     |
|------|--------|
| %M | 日志文本 |
| %L | 日志级别 |
| %l | 行数 |
| %F | 文件名 |
| %f | 函数名 |
| %D | 日期(目前仅支持yyyy-MM-dd HH:mm:ss.SSS) |
| %T | 线程，如果主线程不显示，子线程显示地址 |

代码示例:

```swift
jjLogger.format = "%M %F %L%l %f %D"
```

* 高级使用，根据需要实现自定义接口`JJLogOutput`，示例如下:

```swift
public struct CustomerOutput: JJLogOutput {
    
    /// 自定义队列
    public var queue: DispatchQueue? {
        return nil
    }
    
    /// 重写日志的级别
    public var logLevel: JJSwiftLog.Level {
        get {
            return _consoleLevel
        }
        set {
            _consoleLevel = newValue
        }
    }
    
    /// 获取日志方法
    public func log(_ level: JJSwiftLog.Level, msg: String, thread: String,
     file: String, function: String, line: Int) {
    }
    
}
```

## TODO

* 单元测试

## Linker
* [保护App不闪退](https://github.com/jezzmemo/JJException)

## License
JJSwiftLog is released under the MIT license. See LICENSE for details.



[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JJSwiftLog.svg?style=flat)](http://cocoadocs.org/docsets/JJSwiftLog)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJSwiftLog

使用Unix file descriptor的stdout原理，将日志模块的日志输出到stdout,然后将日志抽象成接口，内置控制台和文件日志，由开发者自行添加，自定义日志可以满足自行分发到任意渠道.

## 主要功能

* 控制台展示(Console Log)

* 日志文件存储(File Log)

* 日志网络存储(Network Log),__暂未实现，后续会加上__

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

* 高级使用，根据需要实现自定义接口`JJLogOutput`，示例如下:

```swift
public struct CustomerOutput: JJLogOutput {
    
    public var queue: DispatchQueue? {
        return 自定义队列
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
     file: String, function: String, line: Int) -> String? {
        return ""
    }
    
}
```

## TODO
* 集成一个三方日志收集

## Linker
* [保护App不闪退](https://github.com/jezzmemo/JJException)

## License
JJSwiftLog is released under the MIT license. See LICENSE for details.



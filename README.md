![Swift4.0+](https://img.shields.io/badge/Swift-4.0%2B-blue.svg?style=flat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JJSwiftLog.svg?style=flat)](http://cocoadocs.org/docsets/JJSwiftLog)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJSwiftLog

![JJSwiftLog screenshot](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/main.png)

延续了Swift日志的简洁，也兼顾了日志的基本功能，文件名，函数名，行数等信息，内置了控制台和文件日志功能,满足开发者的基本需求，自定义日志予以开发者高度灵活的空间

## 主要功能

- [x] 控制台展示(Console Log)，兼顾`NSLog`的特性

- [x] 日志文件存储(File Log)，配置文件日志的高级属性

- [x] 用户自定义日志,继承`JJLogObject`

- [x] 全局开关日志

- [x] 只显示指定文件日志

- [x] 自定义过滤

- [x] 自定义日志格式，任意组合, 内置样式供开发者选择，内置了ANSIColor格式

- [x] 支持多平台iOS,MacOS,Windows和Linux

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

### 快速使用

* 导入模块

```
import JJSwiftLog
```

* 快速入门

一般推荐在程序的入口处，进行初始化，默认配置了控制台和文件日志，只需要配置日志级别即可，以下是示例:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    JJLogger.setup(level: .verbose)

    JJLogger.verbose("verbose")
    JJLogger.debug("debug")
    JJLogger.info("info")
    JJLogger.warning("warn")
    JJLogger.error("error")
}
``` 


### 高级使用

* 开发者自己配置日志

```swift
override func viewDidLoad() {
     super.viewDidLoad()
     // filePath需要存储的路径
     var file = JJFileOutput(filePath: "filePath", delegate: JJLogger, identifier: "file")
     file?.targetMaxFileSize = 1000 * 1024
     file?.targetMaxTimeInterval = 600
     file?.targetMaxLogFiles = 20
     JJLogger.addLogOutput(file)
     #if DEBUG
     JJLogger.addLogOutput(JJConsoleOutput(identifier: "console"))
     #endif
     // 注意startLogInfo调用时机
     JJLogger.startLogInfo()
     JJLogger.verbose("verbose")
     JJLogger.debug("debug")   
     JJLogger.info("info")
     JJLogger.warning("warn")
     JJLogger.error("error")
     // 任意类型
     JJLogger.verbose(123)
     JJLogger.debug(1.2)
     JJLogger.info(Date())
     JJLogger.warning(["1", "2"])
}
```

* `JJConsoleOutput`可以使用 `NSLog`样式,使用`isUseNSLog`属性即可

```swift
let console = JJConsoleOutput()
console.isUseNSLog = false
```

* `JJFileOutput`有几个属性可以调整存储文件策略

    * `targetMaxFileSize`文件最大体积

    * `targetMaxTimeInterval`生成新文件间隔

    * `targetMaxFileSize`文件最大个数，如果超出这个数，就会删除之前的文件

```swift
let file = JJFileOutput()
file?.targetMaxFileSize = 1000 * 1024
file?.targetMaxTimeInterval = 600
file?.targetMaxLogFiles = 20
```

* 使用`enable`，实时开关日志，默认是开启的

```swift
JJLogger.enable = true
```

* 使用`onlyLogFile`方法，让指定文件显示日志

```swift
JJLogger.onlyLogFile("ViewController")
```

* JJSwiftLog支持自定义格式日志，以下表格是简写字母对应关系:

| 简写   | 描述     |
|------|--------|
| %M | 日志文本 |
| %L | 日志级别 |
| %l | 行数 |
| %F | 文件名，不带后缀 |
| %f | 函数名 |
| %D | 日期(目前仅支持yyyy-MM-dd HH:mm:ss.SSSZ) |
| %T | 线程，如果主线程显示main，子线程显示地址或者QueueLabel |
| %t | 显示HH:mm:ss格式 |
| %d | 显示yyyy-MM-dd格式 |
| %N | 文件名，带后缀 |

代码示例:

```swift
JJLogger.format = "%M %F %L%l %f %D"
```

还内置了一些样式，如:`JJLogger.format = JJSwiftLog.simpleFormat`,样式如下:

```
2020-04-08 22:56:54.888+0800 -> ViewController:18 - setupVendor(parameter:) method set the parameter
2020-04-08 22:56:54.889+0800 -> ViewController:28 - viewDidLoad() Start the record
2020-04-08 22:56:54.889+0800 -> ViewController:29 - viewDidLoad() Debug the world
2020-04-08 22:56:54.890+0800 -> ViewController:30 - viewDidLoad() Show log info
2020-04-08 22:56:54.890+0800 -> ViewController:31 - viewDidLoad() Build warning
2020-04-08 22:56:54.890+0800 -> ViewController:32 - viewDidLoad() can’t fetch user info without user id
```

* 根据需要实现自定义接口`JJLogObject`，示例如下:

```swift
public class CustomerOutput: JJLogObject {
    ///重写output即可
    open override func output(log: JJLogEntity, message: String) {

    }
    
}
```

* 每个`JJLogObject`对应有一个`formatters`(格式化)和`filters`(过滤)的属性，根据自己的需求可以定制格式化和过滤器，示例如下:

```swift
open class CustomerFormatter: JJLogFormatterProtocol {
    public func format(log: JJLogEntity, message: String) -> String {
        return ""
    }
}
```

```swift
open class CustomerFilter: JJLogFilter {
    func ignore(log: JJLogEntity, message: String) -> Bool {
        return false
    }
}
```

* 内置了`JJFormatterLogANSIColor`，可以用终端查看用颜色的日志，只需要在`formatters`加入如下:

**控制台不支持ANSIColor模式，目前只在终端上测试通过**

```swift
let file = JJFileOutput(delegate: JJLogger, identifier: "file")
file?.targetMaxFileSize = 1000 * 1024
file?.targetMaxTimeInterval = 600
file?.targetMaxLogFiles = 20
file?.formatters = [JJFormatterLogANSIColor()]
JJLogger.addLogOutput(file!)
```

显示的样式如下:

![JJSwiftLog ANSIColor](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/ansicolor.png)

* 支持Sentry网络日志, 使用示例如下：

```swift
let sentry = JJSentryOutput(sentryKey: "key", 
sentryURL: URL(string: "http://www.exmaple.com/api/5/store/")!, delegate: JJLogger)
sentry.completion = { result in
}
sentry.failure = { error in
}
JJLogger.addLogOutput(sentry)
```


## FAQ

* [0.0.x如何升级到0.1.x](https://github.com/jezzmemo/JJSwiftLog/wiki/JJSwiftLog%E5%A6%82%E4%BD%95%E5%8D%87%E7%BA%A7%E5%88%B00.1.0)

## TODO(记得给我星哦)

* 优化文件存储

## Linker
* [保护App不闪退](https://github.com/jezzmemo/JJException)

## License
JJSwiftLog is released under the MIT license. See LICENSE for details.



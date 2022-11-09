![Swift4.0+](https://img.shields.io/badge/Swift-4.0%2B-blue.svg?style=flat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)](https://img.shields.io/cocoapods/v/JJSwiftLog.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JJSwiftLog.svg?style=flat)](http://cocoadocs.org/docsets/JJSwiftLog)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJSwiftLog

![JJSwiftLog screenshot](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/main.png)

Keep the Swift log concise, and also take into account the basic functions of the log, file name, function name, number of lines and other information, built-in console and file log functions, to meet the basic needs of developers, custom logs for developers to be highly flexible.

## Feature

- [x] Console display (Console Log), taking into account the features of `NSLog`

- [x] Log file storage (File Log), advanced properties of configuration file log

- [x] User-defined log, inherits `JJLogObject`

- [x] Global switch log

- [x] Show only the specified file log

- [x] Custom log filter

- [x] Custom log format, any combination, built-in styles for developers to choose, built-in ANSIColor format

- [x] Supports multi-platform iOS, MacOS, Windows and Linux

## Install

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

## How to use

### Quick to use

* Import module

```
import JJSwiftLog
```

* Quick start

It is generally recommended to initialize at the entry of the program. The console and file log are configured by default. You only need to configure the log level. example:

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


### Advanced

* The developer configures the log

```swift
override func viewDidLoad() {
     super.viewDidLoad()
     // filePath needs to store the path
     var file = JJFileOutput(filePath: "filePath", delegate: JJLogger, identifier: "file")
     file?.targetMaxFileSize = 1000 * 1024
     file?.targetMaxTimeInterval = 600
     file?.targetMaxLogFiles = 20
     JJLogger.addLogOutput(file)
     #if DEBUG
     JJLogger.addLogOutput(JJConsoleOutput(identifier: "console"))
     #endif
     // Note the timing of the startLogInfo call
     JJLogger.startLogInfo()
     JJLogger.verbose("verbose")
     JJLogger.debug("debug")   
     JJLogger.info("info")
     JJLogger.warning("warn")
     JJLogger.error("error")
     // Any type
     JJLogger.verbose(123)
     JJLogger.debug(1.2)
     JJLogger.info(Date())
     JJLogger.warning(["1", "2"])
}
```

* `JJConsoleOutput` use the `NSLog` style, use the `isUseNSLog` property

```swift
let console = JJConsoleOutput()
console.isUseNSLog = false
```

* `JJFileOutput`There are several properties to adjust the storage file strategy

    * `targetMaxFileSize`Maximum file size

    * `targetMaxTimeInterval`Generate new file interval

    * `targetMaxFileSize`The maximum number of files, if this number is exceeded, the previous files will be deleted

```swift
let file = JJFileOutput()
file?.targetMaxFileSize = 1000 * 1024
file?.targetMaxTimeInterval = 600
file?.targetMaxLogFiles = 20
```

* Set `enable` to switch logging in real time, which is enabled by default

```swift
JJLogger.enable = true
```

* Set the `onlyLogFile` method to make the specified file display logs

```swift
JJLogger.onlyLogFile("ViewController")
```

* JJSwiftLog supports custom format logs. The following table is the correspondence between abbreviated letters:

| Shorthand   | Describtion     |
|------|--------|
| %M | log text |
| %L | log level |
| %l | log line |
| %F | filename, without suffix |
| %f | Function name |
| %D | Date (currently only yyyy-MM-dd HH:mm:ss.SSSZ is supported) |
| %T | Thread, if the main thread displays main, the child thread displays the address or QueueLabel |
| %t | Display HH:mm:ss format |
| %d | Display yyyy-MM-dd format |
| %N | filename, with suffix |

Example:

```swift
JJLogger.format = "%M %F %L%l %f %D"
```

There are also built-in styles, such as: `JJLogger.format = JJSwiftLog.simpleFormat`, example:

```
2020-04-08 22:56:54.888+0800 -> ViewController:18 - setupVendor(parameter:) method set the parameter
2020-04-08 22:56:54.889+0800 -> ViewController:28 - viewDidLoad() Start the record
2020-04-08 22:56:54.889+0800 -> ViewController:29 - viewDidLoad() Debug the world
2020-04-08 22:56:54.890+0800 -> ViewController:30 - viewDidLoad() Show log info
2020-04-08 22:56:54.890+0800 -> ViewController:31 - viewDidLoad() Build warning
2020-04-08 22:56:54.890+0800 -> ViewController:32 - viewDidLoad() can’t fetch user info without user id
```

* Implement the custom interface `JJLogObject` as needed, the example:

```swift
public class CustomerOutput: JJLogObject {
    ///重写output即可
    open override func output(log: JJLogEntity, message: String) {

    }
    
}
```

* Each `JJLogObject` corresponds to a `formatters` (formatting) and `filters` (filtering) attributes. You can customize the formatting and filters according to your own needs. Example:

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

* Built-in `JJFormatterLogANSIColor`, you can use the terminal to view the log with color, just add the following in `formatters`:

**The xcode console does not support ANSIColor mode, currently only tested on the terminal**

```swift
let file = JJFileOutput(delegate: JJLogger, identifier: "file")
file?.targetMaxFileSize = 1000 * 1024
file?.targetMaxTimeInterval = 600
file?.targetMaxLogFiles = 20
file?.formatters = [JJFormatterLogANSIColor()]
JJLogger.addLogOutput(file!)
```

Example:

![JJSwiftLog ANSIColor](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/ansicolor.png)

* Support __Sentry__, example：

```swift
let sentry = JJSentryOutput(sentryKey: "key", 
sentryURL: URL(string: "http://www.exmaple.com/api/5/store/")!, delegate: JJLogger)
sentry.completion = { result in
}
sentry.failure = { error in
}
JJLogger.addLogOutput(sentry)
```


## Linker
* [Guard iOS App](https://github.com/jezzmemo/JJException)
* [中文说明](https://github.com/jezzmemo/JJSwiftLog/blob/master/README_CN.md)

## License
JJSwiftLog is released under the MIT license. See LICENSE for details.



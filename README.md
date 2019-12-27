# JJSwiftLog

主要承载iOS各个级别功能，主要体现在控制台，文件，网络三个部分


# 主要功能

* 控制台展示(Console Log)

* 日志文件存储(File Log)

* 日志网络存储(Network Log)

# 如何安装

__Podfile__


```
pod 'JJSwiftLog'
```

# 如何使用

* 导入模块

```
import JJSwiftLog
```

* 使用示例，__setup必须的__

```
func setupLog() {
    swiftLog.addLogOutput(JJFileOutput()!)
    swiftLog.addLogOutput(JJConsoleOutput())
}

override func viewDidLoad() {
     super.viewDidLoad()
     setupLog()
     swiftLog.verbose("verbose")
     swiftLog.debug("debug")   
     swiftLog.info("info")
     swiftLog.warning("warn")
     swiftLog.error("error")
}
```

# TODO
* 集成一个三方日志收集



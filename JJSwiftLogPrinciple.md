# JJSwiftLog设计文档

JJSwiftLog的日志类型，是非用户行为和埋点日志库，因为这两种日志有自己特定的业务领域特性，所以我在给JJSwiftLog是这么定位的

在开发这个库的时候，我们要给它设定一个目标，这个日志库给我们解决什么问题，为什么需要一个日志库来辅助我们开发，以及日志库的价值是什么，我总结的以下几个点:

* 调试开发

开发阶段输出辅助开发的重要信息，帮助快速定位信息，提高查找问题的效率，同时也要展示重要信息

* 排除线上问题

日志会记录重要路径的信息，以及记录各类错误信息，排查问题除了debug之外的有效手段

* 记录重要信息

各个业务都会记录重要信息给日志，让日志库保存到我们想保存的位置，方便我们查看和分析

# 问题

日志库需要注意的问题，I/O和CPU的占有率问题，尽可能的减少对系统的影响，让接入方对这点没有顾虑，性能问题，作为日志库不希望影响整体app的流畅度，能快速处理所有情况，这个是对日志库的基本要求，还有一个就是稳定性，这也是日志库的基本要求，安全性，本地存储或者网络存储需要注意的问题，来保证信息不被泄露和篡改

## 架构位置和冗余设计

日志应该是最基础的库之一，应该是最底层的库，供底层和业务服务，从层次来说应该再最下面，当然如果有些库想不依赖的特殊情况除外，因为下面会提到安全和网络这块，我的理解是这块可能需要我们通过冗余的设计来解决依赖的问题，来保证日志库的内聚，尽量减少外部耦合，让接入者感受到轻量，但是在使用时功能恰到好处，这就是我对日志库设计原则

![JJSwiftLog architecture](https://raw.githubusercontent.com/jezzmemo/JJSwiftLog/master/screenshots/architecture.png)

## 日志性能

* NSLOG

ASL, 通过client connection发送日志，device console AND the debugger console

* os_log

iOS 10以后才提供的，提供多种日志级别，需要import os，device console AND the debugger console

* print

只会显示在debug console

* stdin,stdout,stderr

根据UNIX的一切皆为文件的特性，任何进程都有一个输入，两个输出

## 日志稳定性

为什么会提到这点，是以为他的使用频率和使用场景多，所以日志库在稳定性要求是很高的，接入者是不能接受出bug的可能性，所以我们要保证自己的稳定性，提出相对比较高的要求，平时我们是如何做到的：

1. 架构设计要通过核心开发人员评审
2. PR代码最少需要两位高级开发人员review
3. 要求写UnitTest，逐步提高覆盖率
4. 比较大的调整通过业务方的灰度发布

## 日志安全性

> 安全是相对的，没有绝对的

本次持久化和网络存储都需要注意数据安全问题，常规的应对方法是：

* 对称加密（DES、3DES、DESX、Blowfish、IDEA、RC4、RC5、RC6、AES。 DES. DES）

* 非对称加密（RSA、Elgamal、背包算法、Rabin、D-H、ECC)

通过以上的手段，当日志在存储和传输时，都需要将信息通过Key来恢复，每个公司对这个重视程度不一样，所以这部分根据自己实际情况来实现，不过强烈建议还是需要加密下，来保证数据的安全

## 日志分片（扩展）

## 日志回捞（扩展）

# 参考

[https://github.com/DaveWoodCom/XCGLogger](https://github.com/DaveWoodCom/XCGLogger)
[SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)
[https://github.com/emaloney/CleanroomLogger](https://github.com/emaloney/CleanroomLogger)